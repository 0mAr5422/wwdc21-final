import UIKit
enum Section : CaseIterable {
    case main;
}

public class PathFinding: UIViewController {
    
    
    let graph : Graph = Graph(list: [])
   
    public static var chosenAlgo : Algorithms! = nil
    
    static var nodeSize = CGSize(width: 30 , height: 30)
    static let reuseIdentifier = "cell-id"
    
    var collectionView : UICollectionView! = nil
    var dataSource : UICollectionViewDiffableDataSource<Section , Node>! = nil
  
    
    
    
    var changeSequence : [Node] = []
    
    var currentlyChanging = -1
    
    
    var newMap : Bool = true
    var isFinding : Bool = false
    
    var markCellAsStart : UITapGestureRecognizer! = nil
    var markCellAsTarget : UILongPressGestureRecognizer! = nil
    var markCellAsBlocked : UIPanGestureRecognizer! = nil
    
    var shouldHighlight : Bool = false {
        didSet {
            if pathFromStartToTarget.count < 1 {
                isFinding = false
                
                disableAllGestures()
                if newMap == false {
                    title = "cannot find target"
                }
                else {
                    updateTitle()
                }
                
                return
            }
            if newMap {
                updateTitle()
            }
            else {
                title = "FOUND!!"
            }
            
            var mini = 100000
            var index = -1 ;
            for i in 0..<pathFromStartToTarget.count {
                if pathFromStartToTarget[i].count < mini {
                    mini = pathFromStartToTarget[i].count
                    index = i
                }
            }
       
            if pathFromStartToTarget[index].count >= 1 {
                pathFromStartToTarget[index].popLast()
            }
            if pathFromStartToTarget[index].count >= 1 {
                pathFromStartToTarget[index].removeFirst()
            }
            highlightPath(index: 0,outer: index)
            disableAllGestures()
        }
    }
    
    var startNode : Int = -100;
    var targetNode : Int = -100;
    
    var pathFromStartToTarget : [[Node]] = []
    
    public override func viewDidLoad() {
        view.backgroundColor = .white
        updateTitle()
        configureNavItem()
        configureCollectionView()
        configureDataSource()
    }
    
    
    public enum Algorithms {
        case dfs , bfs , dijkstra , bellmanford
    }
    
    
    

    
}
extension PathFinding {
    
    func configureNavItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Find Target",
                                                            style: .plain, target: self,
                                                            action: #selector(findTarget(sender:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear Map", style: .plain, target: self, action: #selector(clearMap(sender:)))
    }
    
    @objc func clearMap(sender : UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        startNode = -100
        targetNode = -100
        graph.list = []
        isFinding = false
        changeSequence = []
        pathFromStartToTarget = []
        newMap = true
        shouldHighlight = false;
        enableAllGestures()
        let snap = randomizedSnapshot(for: collectionView.bounds)
        dataSource.apply(snap)
        
    }
    
    @objc func findTarget(sender : UIBarButtonItem) {
        if startNode == -100 || targetNode == -100 {
            return
        }
        if isFinding == false{
            performSearch()
            sender.isEnabled = false
        }
        else {
            sender.isEnabled = true
        }
        
    }
    
    
    
    func performSearch() {
        
        newMap = false
        switch  PathFinding.chosenAlgo{
        case .dfs:
            var emptyPath : [Node] = []
            dfs(node: graph.list[startNode], path: &emptyPath)
        case .bfs:
            bfs(node: graph.list[startNode])
        case .dijkstra :
            dijkstra(start: startNode, target: targetNode)
        case .bellmanford :
            bellmanFord(start: startNode, target: targetNode)
        default :
            break;
        }
        collectionView.isUserInteractionEnabled = false
        
        updateUI(index: 0)
       
        
        
    }
    
    func updateTitle() {
        switch PathFinding.chosenAlgo {
        case .dfs:
            title = "DFS"
        case .bfs :
            title = "BFS"
        case .dijkstra :
            title = "dijkstra"
        case .bellmanford :
            title = "Bellman-Ford"
        default:
            break
        }
    }
    
    func enableAllGestures() {
        markCellAsBlocked.isEnabled = true
        markCellAsTarget.isEnabled = true
        markCellAsStart.isEnabled = true
    }
    func disableAllGestures() {
        markCellAsBlocked.isEnabled = false
        markCellAsTarget.isEnabled = false
        markCellAsStart.isEnabled = false
    }
    
}

extension PathFinding {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout())
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: PathFinding.reuseIdentifier)
        
        
        markCellAsStart = UITapGestureRecognizer(target: self, action: #selector(markCellAsStart(sender:)))
        markCellAsTarget = UILongPressGestureRecognizer(target: self, action: #selector(markCellAsTarget(sender:)))
        markCellAsBlocked = UIPanGestureRecognizer(target: self, action: #selector(markCellAsBlocked(sender:)))
        markCellAsStart.numberOfTapsRequired = 2
        collectionView.addGestureRecognizer(markCellAsStart)
        collectionView.addGestureRecognizer(markCellAsTarget)
        collectionView.addGestureRecognizer(markCellAsBlocked)
    }
    
    @objc private func markCellAsBlocked(sender : UIPanGestureRecognizer) {
       newMap = false
        
        let location = sender.location(in: collectionView)
        for subview in collectionView.subviews {
            if subview.frame.contains(location) {
                var snap = dataSource.snapshot()
                guard let cell = subview as? UICollectionViewCell else {return }
                guard let  item = collectionView.indexPath(for: cell) else {return}
                if item.item == startNode || item.item == targetNode {
                    return
                }
                let realItem = snap.itemIdentifiers[item.item]
                realItem.canVisit = false
                snap.reloadItems([realItem])
                dataSource.apply(snap)
            }
            
        }
    }
    @objc private func markCellAsTarget(sender:UILongPressGestureRecognizer) {
        newMap = false
        let location = sender.location(in: collectionView)
        for subview in collectionView.subviews {
            if subview.frame.contains(location) {
                var snap = dataSource.snapshot()
                guard let cell = subview as? UICollectionViewCell else {return }
                guard let  item = collectionView.indexPath(for: cell) else {return}
                let realItem = snap.itemIdentifiers[item.item]
                if item.item == startNode || realItem.canVisit == false{
                    return
                }
                var oldItem : Node! = nil
                if targetNode != -100 {
                    oldItem = graph.list[targetNode]
                    snap.reloadItems([oldItem])
                }
                
                targetNode = collectionView.indexPath(for: subview as! UICollectionViewCell)!.item
                
                snap.reloadItems([realItem])
                dataSource.apply(snap)
                
            }
        }
    }
    
    @objc private func markCellAsStart(sender : UITapGestureRecognizer) {
        newMap = false
        let location = sender.location(in: collectionView)
        for subview in collectionView.subviews {
            if subview.frame.contains(location) {
                var snap = dataSource.snapshot()
                guard let cell = subview as? UICollectionViewCell else {return }
                guard let  item = collectionView.indexPath(for: cell) else {return}
                let realItem = snap.itemIdentifiers[item.item]
                if item.item == targetNode || realItem.canVisit == false{
                    return
                }
                var oldItem : Node! = nil
                if startNode != -100 {
                    oldItem = graph.list[startNode]
                    snap.reloadItems([oldItem])
                }
                
                startNode = collectionView.indexPath(for: subview as! UICollectionViewCell)!.item
                
                snap.reloadItems([realItem])
                dataSource.apply(snap)
            }
            
        }
        
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section , Node>(collectionView : self.collectionView) { [self]
            (collectionView : UICollectionView , indexPath : IndexPath , sortNode : Node) in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PathFinding.reuseIdentifier,
                    for: indexPath)
            
            if newMap {
                cell.backgroundColor = .white
                
            }
            else {
                if sortNode.canVisit == false {
                    cell.backgroundColor = .black
                }
                else {
                    cell.backgroundColor = .white
                    if startNode != -100 && sortNode == graph.list[startNode] {
                        cell.backgroundColor = .systemPurple
                    }
                    if targetNode != -100 && sortNode == graph.list[targetNode] {
                        cell.backgroundColor = .systemYellow
                    }
                    
                    else if sortNode.visited == true && indexPath.item <= currentlyChanging && sortNode != graph.list[startNode] && sortNode != graph.list[targetNode]{
                        cell.backgroundColor = .systemTeal
                    }
                    
                    if sortNode.isFromPath == true {
                        cell.backgroundColor = .systemRed
                    }
                }
                
            }
            

            cell.contentView.layer.borderWidth = 0.5
            cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        
            let label = UILabel(frame: cell.contentView.bounds)
            label.text = "\(sortNode.value)"
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 9)
//                cell.contentView.addSubview(label)
            
                return cell
            
        }
        
        let bounds = collectionView.bounds
        let snapshot = randomizedSnapshot(for: bounds)
        dataSource.apply(snapshot)
    }
    
    private func randomizedSnapshot(for bounds : CGRect) -> NSDiffableDataSourceSnapshot
    <Section , Node>{
        newMap = true
        var snapshot = NSDiffableDataSourceSnapshot<Section, Node>()
        let rowCount = numberOfRows(for: bounds)
        let columnCount = numberOfCols(for: bounds)
        snapshot.appendSections([Section.main])
        currentlyChanging = -1
        graph.generateMap(rowCount: rowCount, columnCount: columnCount)
        snapshot.appendItems(graph.list)
        
        return snapshot
    }
    
    private func numberOfRows(for bounds: CGRect) -> Int {
        return Int(bounds.height / PathFinding.nodeSize.height)
    }
    private func numberOfCols(for bounds: CGRect) -> Int {
        return Int(bounds.width / PathFinding.nodeSize.width)
    }
    
    
    private func layout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
           (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
           let contentSize = layoutEnvironment.container.effectiveContentSize
           let columns = Int(contentSize.width / PathFinding.nodeSize.width)
           let rowHeight = PathFinding.nodeSize.height
           let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
           let item = NSCollectionLayoutItem(layoutSize: size)
           let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(rowHeight))
           let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
           let section = NSCollectionLayoutSection(group: group)
           return section
       }
       return layout
       
    }
}


extension PathFinding : UICollectionViewDelegate {
    
}
extension PathFinding {
    func highlightPath(index : Int , outer : Int) {
        
        if index >= pathFromStartToTarget[outer].count {
            collectionView.isUserInteractionEnabled = true
            return
        }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredVertically, animated: true)
        let node = pathFromStartToTarget[outer][index]
        currentlyChanging = node.value
        
        
        var snap = dataSource.snapshot()
        node.isFromPath = true
        snap.reloadItems([node])
        dataSource.apply(snap)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25)) {[self] in
            
            self.highlightPath(index: index+1,outer: outer)
        }
    }
    
    func updateUI(index : Int) {
        
        if index >= changeSequence.count {
            collectionView.isUserInteractionEnabled = true
            shouldHighlight = true
            return
        }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredVertically, animated: true)
        let node = changeSequence[index]
        currentlyChanging = node.value
        
        
        var snap = dataSource.snapshot()
        node.visited = true
        snap.reloadItems([node])
        dataSource.apply(snap)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25)) {[self] in
            
            self.updateUI(index: index+1)
        }
        
    }
    
    func bfs(node : Node  ) {
        var parent : [[Int]] = [];
        
        for _ in 0..<graph.list.count+1 {
            parent.append([])
        }
        parent[startNode+1].append(-1);
        
        
        var q : [Node] = [];
        q.append(node);
        node.visited = true
        
        changeSequence.append(node)
        while q.count > 0 {
            let front = q[0]
            q.removeFirst()

            
            
            if front == graph.list[targetNode] {
                
                var paths : [[Node]] = []
                var path : [Node] = []
                findPaths(paths: &paths, path: &path, parent: parent, u: targetNode+1)
                var mini = 10000
                var index = 0 ;
                for i in 0..<paths.count {
                    if paths[i].count < mini {
                        mini = paths[i].count
                        index =  i
                    }
                }
                pathFromStartToTarget.append(paths[index])
                return
            }

            for i in front.connections {
                if i.visited || i.canVisit == false{
                    continue
                }

                i.visited = true
                
                changeSequence.append(i)
                q.append(i)
                parent[i.value].append(front.value)
            }
        }

    }


    func dfs(node : Node , path : inout [Node] ) -> Bool {
        node.visited = true
        changeSequence.append(node)
        path.append(node)
        if node == graph.list[targetNode] {
            pathFromStartToTarget.append(path)
            return true
        }
        for x in node.connections {
            
            if x.visited || x.canVisit == false || pathFromStartToTarget.count >= 1{
                
                continue
            }
            
            if self.dfs(node: x,path: &path ) == true {
                return false
            }
                
            }
            
        
       return false
    }
    
    func dijkstra(start : Int , target : Int) {
        var parent : [[Int]] = [];
        var distance : [Double] = [];
        
        for _ in 0..<graph.list.count+1 {
            distance.append(Double.greatestFiniteMagnitude)
            parent.append([])
        }

        var q : [Node] = []
        
        distance[start+1] = 0.0
    
        q.append(graph.list[start])
        
        parent[start+1].append(-1);
        
        while q.count > 0 {
            var index = findMinimum(q: q, distance: distance)
            let a = q[index]
            q.remove(at: index)
            changeSequence.append(a)
            if a.visited || a.canVisit == false{
                continue
            }
            if a == graph.list[target] {
                break
            }
            
            a.visited = true
            for i in a.connections {
                if (distance[a.value] + 1 < distance[i.value] )  {
                    distance[i.value] = distance[a.value] + 1;
                    q.append(i)
                    q.sort {
                        distance[$0.value] < distance[$1.value]
                    }
                    parent[i.value] = [a.value]
                }
                else if (distance[a.value] + 1 == distance[i.value] ) {
                    parent[i.value].append(a.value)
                }
            }
        }
    
        var paths : [[Node]] = [[]]
        var path2 : [Node] = [];
        
        
        findPaths(paths: &paths, path: &path2, parent: parent, u: targetNode+1)
        if distance[targetNode+1] < Double.greatestFiniteMagnitude {
            pathFromStartToTarget.append(paths.last!)
        }
        
    }
    
    
    func findMinimum(q : [Node] , distance : [Double]) -> Int{
        var mini = 10000.0;
        var index = -1;
        for i in 0..<q.count {
            if distance[q[i].value] < mini {
                mini = distance[q[i].value]
                index = i
            }
        }
        return index
    }
    
    func findPaths(paths : inout [[Node]] , path : inout [Node] , parent : [[Int]] , u : Int ) {
        
        if u == -1 {
            
            let temp = path
            paths.append(temp)
            return
        }
        
        for par in parent[u] {
            path.append(graph.list[u-1])
            findPaths(paths: &paths, path: &path, parent: parent, u: par)
            path.popLast()
        }
        
        
    }
    
    func bellmanFord(start : Int , target : Int) {
        var edges = graph.generateEdges()
        
        var distance : [Double] = []
        var parent : [Int] = (0...graph.list.count).map {_ in -1}
        
        for _ in 0...graph.list.count {
            distance.append(Double.greatestFiniteMagnitude)
        }
        distance[start+1] = 0
        
        outer : for i in 1...graph.list.count {
            for e in edges {
                if e.0.canVisit == false || e.1.canVisit == false {
                    continue
                }
                if distance[e.1.value]+1 < distance[e.0.value] {
                    distance[e.0.value] = distance[e.1.value]+1;
                    if !changeSequence.contains(e.0) {
                        changeSequence.append(e.0)
                    }
                    
                    parent[e.0.value] = e.1.value
                }
                
               
            }
        }
        
        var paths : [[Node]] = [[]]
        var path2 : [Node] = [];
        
        
        findBellmanFordPath(paths: &paths, path: &path2, parent: parent, u: targetNode+1)
        if distance[targetNode+1] < Double.greatestFiniteMagnitude {
            pathFromStartToTarget.append(paths.last!)
        }
        
    }
    
    func findBellmanFordPath(paths : inout [[Node]] , path : inout [Node] , parent : [Int] , u : Int) {
        if u == -1 {
            var temp = path
            paths.append(temp)
            return
        }
        path.append(graph.list[u-1])
        findBellmanFordPath(paths: &paths, path: &path, parent: parent, u: parent[u])
        path.popLast()
    }
    
    

}
