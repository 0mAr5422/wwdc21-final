//
//  ViewController.swift
//  Algo Visualizer 2.0 app
//
//  Created by Omar Nader on April/17/21.
//

import UIKit

public class PathFindingViewController: UIViewController {
    enum Section {
        case main
    }
    var collectionView : UICollectionView! = nil
    var dataSource : UICollectionViewDiffableDataSource<Section,AlgorithmItem>! = nil
    
    
    class AlgorithmItem: Hashable {
           let title: String
           let info : String
           let timeComplexity : String;
           let characteristics : String
           let algorithmViewController: UIViewController.Type?
           let algorithm : PathFinding.Algorithms

           init(algorithm : PathFinding.Algorithms,title: String,
                timeComplexity:String,
                characteristics : String,
                info: String,
                viewController: UIViewController.Type? = nil){
               self.algorithm = algorithm
               self.title = title
               self.info = info
               self.timeComplexity = timeComplexity
               self.characteristics = characteristics
               self.algorithmViewController = viewController
           }
           func hash(into hasher: inout Hasher) {
               hasher.combine(identifier)
           }
           static func == (lhs: AlgorithmItem, rhs: AlgorithmItem) -> Bool {
               return lhs.identifier == rhs.identifier
           }
           var isGroup: Bool {
               return self.algorithmViewController == nil
           }
           private let identifier = UUID()
       }
    
    
    
    private lazy var algorithms : [AlgorithmItem] = [
        
         AlgorithmItem(algorithm: .dfs, title: "DFS",timeComplexity:"Time: O(V + E) , Space:O(V)",characteristics: "Un-Weighted", info: "DFS is a graph traversal and searching algorithm , dfs doesn't use weights so it doesn't guarantee finding the shortest path between two nodes ", viewController: PathFinding.self),
        AlgorithmItem(algorithm: .bfs, title: "BFS",timeComplexity: "Time: O(V + E) , Space:O(V)",characteristics: "Weighted" ,info: "BFS is a graph traversal and search algorithm , bfs uses weights to make sure to choose the node with the least weight to visit next , bfs guarantees finding the shortest path between any two given nodes ", viewController: PathFinding.self),
        AlgorithmItem(algorithm: .dijkstra, title: "Dijkstra's",timeComplexity: "Time: O((V + E) log(V)) ,Space: O(V)",characteristics: "weighted" ,info: "Dijkstra is a path finding greedy algorithms that uses weights to choose the best node to visit next , dijkstra guarantees finding the shortest path between any two given nodes   ", viewController: PathFinding.self),
        AlgorithmItem(algorithm: .bellmanford, title: "Bellman-Ford",timeComplexity: "Time: O(VE) ,Space: O(V)",characteristics: "weighted" ,info: "Bellman-Ford's algorithm calculates the distance between a source node and every other node in the graph , Bellman-Ford's algorithms guarantees finding the shortest path between any two given nodes", viewController: PathFinding.self),
       
    ]
    
    
    
    public override func viewDidLoad() {
        
        
        
    
        title = "Path-Finding"
        configureCollectionView()
        configureDataSource()
        
       
        
        
    }
    
    
    
}



extension PathFindingViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.register(AlgorithmCardCell.self, forCellWithReuseIdentifier: AlgorithmCardCell.reuseIdentifier)
    }
    
    private func  configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource
            <Section, AlgorithmItem>(collectionView: self.collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: AlgorithmItem) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlgorithmCardCell.reuseIdentifier,
                for: indexPath) as? AlgorithmCardCell else { fatalError("Could not dequeue algorithm card cell") }
                cell.algoName.text = item.title
                cell.algoInfo.text = item.info
                cell.timeAndSpaceComplexity.text = item.timeComplexity
                cell.algoCharacteristics.text = item.characteristics
                
                
            return cell
        }

        // load our initial data
        let snapshot = snapshotForCurrentState()
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    
    
    private func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, AlgorithmItem>{
        var snapshot = NSDiffableDataSourceSnapshot<Section, AlgorithmItem>()
        snapshot.appendSections([Section.main])
        func addItems(_ menuItem: AlgorithmItem) {
            snapshot.appendItems([menuItem])
            
        }
        self.algorithms.forEach { addItems($0) }
        return snapshot
        
    }
    
    private func layout() -> UICollectionViewLayout {
        let size = NSCollectionLayoutSize(
               widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
               heightDimension: NSCollectionLayoutDimension.fractionalHeight(1)
               )
               let item = NSCollectionLayoutItem(layoutSize: size)
               item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 30, bottom: 5, trailing: 30)
               
               
               let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.555))
               let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
               
               
               let section = NSCollectionLayoutSection(group: group)
               section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)

           
               let layout = UICollectionViewCompositionalLayout(section: section)
               return layout
    }
}

extension PathFindingViewController : UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AlgorithmCardCell else {return}
        guard let algoItem = dataSource.itemIdentifier(for: indexPath) else {return}
        
        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
        
        if let viewController = algoItem.algorithmViewController  {
            let navController = UINavigationController(rootViewController: viewController.init())
            PathFinding.chosenAlgo = algoItem.algorithm
            present(navController, animated: true)
            UIView.animate(withDuration: 0.2) {
                cell.transform = .identity
            }
        }
            
        }
    
}




