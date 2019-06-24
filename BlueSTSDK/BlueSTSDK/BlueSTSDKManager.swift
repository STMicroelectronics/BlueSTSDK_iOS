import Foundation

@objc public class BlueSTSDKManager : NSObject{
    private static let RETRAY_START_SCANNING_DELAY = TimeInterval(0.5)
    public static let DEFAULT_ADVERTISE_FILTER:[BlueSTSDKAdvertiseFilter] = [BlueSTSDKAdvertiseParser()];
    
    @objc public static let sharedInstance = BlueSTSDKManager()
    /**
     *  Get all the discovered nodes
     *
     *  @return array of {@link BlueSTSDKNode} with all the discovered nodes
     */
    @objc private(set) public var nodes:[BlueSTSDKNode] = []
    
    /**
     *  Tell if the manager is in a discovery state
     *
     *  @return true if the manager is seaching for new nodes
     */
    @objc private(set) public var isDiscovering:Bool = false {
        didSet{
            mListeners.forEach{ listener in
                mNotificationQueue.async {
                    listener.manager(self, didChangeDiscovery: self.isDiscovering)
                }
            }
        }
    }
    
    private var mListeners:[BlueSTSDKManagerDelegate] = []
    private let mNotificationQueue = DispatchQueue(label: "BlueSTSDKMenager",qos: .background, attributes: .concurrent)
    private var mNodeFeatures:[UInt8:[NSNumber:BlueSTSDKFeature.Type]] = [:]
    private var mCBCentralManager:CBCentralManager!
    private var mAdvertiseFilters:[BlueSTSDKAdvertiseFilter]=BlueSTSDKManager.DEFAULT_ADVERTISE_FILTER
    
    private override init() {
        super.init()
        mCBCentralManager = CBCentralManager(delegate: self, queue: nil)
        let  defaultFeatureMap = BlueSTSDKBoardFeatureMap.boardFeatureMap
        defaultFeatureMap.forEach{ boardId, featureMap in
            mNodeFeatures[boardId.uint8Value] = featureMap
        }
    }
    
    @objc public func discoveryStart(){
        discoveryStart(-1)
    }
    
    @objc public func discoveryStart(_ timeoutMs:Int ){
        discoveryStart(timeoutMs, advertiseFilters: BlueSTSDKManager.DEFAULT_ADVERTISE_FILTER)
    }
    /**
     *  Start a discovery process that will scan for a new node. The discovery will
     * stop after {@code timeoutMs} milliseconds
     *
     *  @param timeoutMs milliseconds to wait before stop the scanning
     */
    @objc public func discoveryStart(_ timeoutMs:Int, advertiseFilters: [BlueSTSDKAdvertiseFilter] ){
        guard mCBCentralManager.state == .poweredOn  && isDiscovering == false else{
            mNotificationQueue.asyncAfter(deadline: .now()+BlueSTSDKManager.RETRAY_START_SCANNING_DELAY){
                self.discoveryStart(timeoutMs,advertiseFilters: advertiseFilters)
            }
            return
        }
        let scanOptions:[String : Any] = [CBCentralManagerScanOptionAllowDuplicatesKey:true]
        mAdvertiseFilters = advertiseFilters
        mCBCentralManager.scanForPeripherals(withServices: nil, options: scanOptions)
        isDiscovering = true
        let delay = TimeInterval(timeoutMs)/1000.0
        if(delay>0){
            mNotificationQueue.asyncAfter(deadline: .now() + delay){
                self.discoveryStop()
            }
        }
    }
    
    /**
     *  Stop the discovery process
     */
    @objc public func discoveryStop(){
        guard mCBCentralManager.state == .poweredOn else {
            return
        }
        guard isDiscovering == true else{
            return
        }
        mCBCentralManager.stopScan()
        isDiscovering = false
    }
 
    //TODO: swift: use defailt parameters
    @objc public func resetDiscovery(){
        resetDiscovery(true)
    }
    /**
     *  Remove all the discovered nodes
     *  @param force if true remove also the connected nodes
     */
    @objc public func resetDiscovery(_ disconnectAll:Bool){
        if(disconnectAll){
            nodes.forEach{ node in
                if(node.isConnected()){
                    node.disconnect()
                }
            }
        }
        //remove all disconnected node
        nodes.removeAll{ node in
            !node.isConnected()
        }
    }
    
    fileprivate func addAndNotify(node: BlueSTSDKNode){
        guard !nodes.contains(node) else{
            return
        }
        nodes.append(node)
        mListeners.forEach{ listener in
            mNotificationQueue.async {
                listener.manager(self, didDiscoverNode: node)
            }
        }
    }
    
    /**
     *  add a new node and call all the delegate for notify the discovery of a new node
     *
     *  @param node new discovered node
     */
    @objc public func addVirtualNode(){
        if let node = BlueSTSDKNodeFake(){
            addAndNotify(node: node)
        }
    }
    
    /**
     *  Search in the discovered node the one that has a particular name,
     *  @note the node name is not unique so we will return the first node that match the name
     *
     *  @param name node name to search
     *
     *  @return a node with the name, or nil if a node with that name doesn't exist
     */
    @objc public func nodeWith( name:String)->BlueSTSDKNode?{
        return nodes.first{ $0.name == name}
    }
    
    /**
     *  Search in the discovered node the one that has a particular tag
     *
     *  @param tag tag to search
     *
     *  @return a node with that tag or nil if the node doesn't exist
     */
    public func nodeWith(tag:String) -> BlueSTSDKNode?{
        return nodes.first{ $0.tag == tag}
    }
 
    private func isValidFeatureMap( featureMap: [UInt32:BlueSTSDKFeature.Type])->Bool{
        return featureMap.keys.allSatisfy{ $0.isValidFeatureMask }
    }
    /**
     *  Add to a node a list of possible feature exported by the node
     *
     *  @param nodeId  new board id or a board id that we want extend
     *  @param features map of new features add to the board, it is a dictionary of
     * <{@link featureMask_t},BlueSTSDKFeature>
     * @throw an exception if the featureMask as more than one bit set to 1
     */
    @objc public func addFeatureForNode(nodeId:UInt8, features:[UInt32:BlueSTSDKFeature.Type]) throws{
        guard isValidFeatureMap(featureMap: features) else{
            NSException(name: NSExceptionName("Invalid feature key data"), reason: "the key must have only one bit set to 1", userInfo: nil).raise()
            return
        }
        
        var currentMap = mNodeFeatures[nodeId] ?? BlueSTSDKBoardFeatureMap.defaultMaskToFeatureMap
        
        features.forEach{ (arg) in
            let (key, feature) = arg
            currentMap[NSNumber(value: key)] = feature
        }
        mNodeFeatures[nodeId] = currentMap
    }
    
    @objc public func getFeaturesForNode(_ nodeId:UInt8)-> [NSNumber : BlueSTSDKFeature.Type]{
        if let featuresMap = mNodeFeatures[nodeId] {
            return featuresMap
        }else {
            return BlueSTSDKBoardFeatureMap.defaultMaskToFeatureMap
        }
        
    }
    
    @objc public func removeDelegate(_ delegate:BlueSTSDKManagerDelegate){
        
        if let index = mListeners.firstIndex(where: {$0 === delegate}){
            mListeners.remove(at: index)
        }
    }
    
    @available(*, deprecated, message: "Use removeDelegate")
    @objc public func remove(_ delegate:BlueSTSDKManagerDelegate){
        removeDelegate(delegate)
    }
    
    @objc public func addDelegate(_ delegate:BlueSTSDKManagerDelegate){
        guard mListeners.firstIndex(where: {$0 === delegate}) == nil else{
            return
        }
        mListeners.append(delegate)
    }
    
    @available(*, deprecated, message: "Use addDelegate")
    @objc public func add(_ delegate:BlueSTSDKManagerDelegate){
        addDelegate(delegate)
    }
    
    //TODO: swift: remove the public when node is rewrited in swift
    @objc public func connect(_ peripheral:CBPeripheral){
        guard mCBCentralManager.state == .poweredOn else{
            return
        }
        mCBCentralManager.connect(peripheral, options: nil)
    }
    
    //TODO: swift: remove the public when node is rewrited in swift
    @objc public func disconnect(_ peripheral:CBPeripheral){
        guard mCBCentralManager.state == .poweredOn else{
            return
        }
        mCBCentralManager.cancelPeripheralConnection(peripheral)
    }
}

@objc public protocol BlueSTSDKManagerDelegate : class {
    /**
     *  Function called when a new node is discovered
     *
     *  @param manager manager that discovered the node (the manger is a singleton,
     *    so this parameter is only for have a consistent method sign with the others delegate)
     *  @param node new node discovered
     */
    func manager(_ manager:BlueSTSDKManager, didDiscoverNode:BlueSTSDKNode)
    
    /**
     *  Function called when the status of the manager change
     *
     *  @param manager manager that discovered the node (the manger is a singleton,
     *    so this parameter is only for have a consistent method sign with the others delegate)
     *  @param enable true if the manger start a scan process, false if it end the scanning
     */
    func manager(_ manager:BlueSTSDKManager, didChangeDiscovery:Bool)
}

extension BlueSTSDKManager : CBCentralManagerDelegate {
    
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let tag = peripheral.identifier.uuidString
        
        
        if let node = nodeWith(tag: tag){
            node.updateRssi(RSSI)
        }else{
            //get the fist value != nil returned by a filter
            let firstMatch = mAdvertiseFilters.lazy.compactMap{ $0.filter(advertisementData)}.first
            if let info = firstMatch{
                let newNode = BlueSTSDKNode(peripheral, rssi: RSSI, advertiseInfo:info)
                addAndNotify(node: newNode)
            }
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager){
        if(central.state != .poweredOn){
            isDiscovering = false
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let tag = peripheral.identifier.uuidString
        if let node = nodeWith(tag: tag){
            node.completeConnection()
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let tag = peripheral.identifier.uuidString
        if let node = nodeWith(tag: tag){
            node.connectionError(error)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let tag = peripheral.identifier.uuidString
        if let node = nodeWith(tag: tag){
            node.completeDisconnection(error)
        }
    }
}

fileprivate extension UInt32 {
    
    var isValidFeatureMask:Bool{
        get{
            return self.nonzeroBitCount == 1
        }
    }
    
}
