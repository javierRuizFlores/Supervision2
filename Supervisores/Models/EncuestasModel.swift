//
//  EncuestasModel.swift
//  Supervisores
//
//  Created by Sharepoint on 8/29/19.
//  Copyright © 2019 Farmacias Similares. All rights reserved.
//

import Foundation
struct scoreItem {
    var id: Int
    var count: Int
}
class EncuestasModel{
    static let shared: EncuestasModel = EncuestasModel()
    var out: EncuestasModelOutput!
    var items: [EncuestasItem] = []{
        didSet{
          setNumberIcon(items: self.items)
        }
    }
    var counts: [Int] = []
    var newEncuestas = 0
    var Score: [[String: Int]] = []
    func load(){
        if items.count > 0{
            
        }
        NetworkingServices.shared.getEncuestas(){
            [unowned self] in
            
            guard let dataResponse = $0,
                $1 == nil else {
                    print($1?.localizedDescription ?? "Response Error")
                    
                    return }
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                print(jsonResponse) //Response result
            } catch let parsingError {
                
            }
            do{
                let items  = try JSONDecoder().decode([EncuestasItem].self, from: dataResponse)
                
                self.items = self.getViableEncuestas(items: items.filter({$0.EstatusEncuesta?.Estatus == "Publicada"}))
                
            }
            catch let error{
                
                print("ErrorDescription\(error.localizedDescription)")
            }
        }
        }
    func setNumberEncuestas(items: [EncuestasItem]) -> ([EncuestasItem],[String:Int]){
        return (items,[:])
    }
    func setNumberIcon(items: [EncuestasItem]){
        let encuestas =  Storage.shared.getEncuestas(idUnit: 0)
        var uptadeItems: [EncuestasItem] = []
        for item in items{
            var existing = false
            for encuesta in encuestas{
                if item.EncuestaId == encuesta.idEncuesta{
                    existing = true
                }
            }
           
            if !existing{
                uptadeItems.append(item)
            }
        }
        
            let num = UserDefaults.standard.integer(forKey: "Encuesta") ?? 0
        self.newEncuestas = uptadeItems.count + num
        UserDefaults.standard.set(self.newEncuestas, forKey: "Encuesta")
        for item in uptadeItems{
            Storage.shared.updateEncuestas(item: item, count: 0)
        }
        
    }
    
    func getViableEncuestas(items: [EncuestasItem]) -> [EncuestasItem]{
        
        
        return items.filter({Utils.isVisibleEncuesta(inicio: Utils.dateFromService(stringDate: $0.FechaInicio!), fin: Utils.dateFromService(stringDate: $0.FechaTermino!))})
    }
    func getScore() {
        NetworkingServices.shared.getScore(id:(LoginViewModel.shared.loginInfo?.user?.domainAccount)!){
            [unowned self] in
        
        guard let dataResponse = $0,
            $1 == nil else {
                print($1?.localizedDescription ?? "Response Error")
                
                return }
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with:
            dataResponse, options: []) as! [String:Int]
            print(jsonResponse) //Response result
            self.Score.append( jsonResponse)
            self.out.modelDidLoad((self.items,jsonResponse))
        } catch let parsingError {
            
        }
        do{
           
        }
        catch let error{
            
            print("ErrorDescription\(error.localizedDescription)")
        }
    }
    }
}
