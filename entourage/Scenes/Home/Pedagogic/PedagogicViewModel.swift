//
//  PedagogicModelView.swift
//  entourage
//
//  Created by Jerome on 09/06/2022.
//

import Foundation


class PedagogicViewModel {
    
    private var _resources = [PedagogicResource]()
    
    var resources:[PedagogicResource] {
        get {
            return _resources
        }
    }
    
    func getResources(completion: @escaping (_ isOk:Bool) -> Void) {
        _resources.removeAll()
        
        HomeService.getResources { resources, error in
            if let resources = resources {
                self._resources.append(contentsOf: resources)
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    var understandResources:PedagogicResources {
        get {
            var resources = PedagogicResources()
            resources.resources = _resources.filter({$0.tag == .Understand})
            resources.title = "resource_title_understand".localized
            return resources
        }
    }
    
    var actResources:PedagogicResources {
        get {
            var resources = PedagogicResources()
            resources.resources = _resources.filter({$0.tag == .Act })
            resources.title = "resource_title_act".localized
            return resources
        }
    }
    
    var inspireResources:PedagogicResources {
        get {
            var resources = PedagogicResources()
            resources.resources = _resources.filter({$0.tag == .Inspire})
            resources.title = "resource_title_inspire".localized
            return resources
        }
    }
    
    var allResources: [PedagogicResources] {
        get {
            var resources = [PedagogicResources]()
            resources.append(understandResources)
            resources.append(actResources)
            resources.append(inspireResources)
            return resources
        }
    }
    
    func markReadResourceId(_ id:Int, completion: @escaping (_ isOk:Bool) -> Void) {
        if let index = _resources.firstIndex(where: {$0.id == id}) {
            
            _resources[index].isRead = true
            completion(true)
        }
    }
}
