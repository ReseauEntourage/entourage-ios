//
//  HomeMainProtocols.swift
//  entourage
//
//  Created by Jerome on 09/06/2022.
//

import Foundation

//MARK: - Protocol HomeMainViewsActionsDelegate -
protocol HomeMainViewsActionsDelegate: AnyObject {
    func showUserProfile(id:Int)
    func editMyProfile()
    
    func showNeighborhoodDetail(id:Int)
    func showAllNeighborhoods()
    func createNeighborhood()
    
    func showPoi(id:Int)
    func showAllPois()
    
    func showWebview(url:String)
    
    func showResources()
    func showResource(id:Int)
    
    func showConversation(conversationId:Int)
    
    
    func showAskForHelpDetail(id:Int)
    func showAllAskForHelp()
    func createAskForHelp()
    
    func showContribution(id:Int)
    func showAllContributions()
    func createContribution()
    
    func showAllOutings()
    func showOuting(id:Int)
}
