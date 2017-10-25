//
//  Beacon.swift
//  BComm
//
//  Created by 野口 威 on 2017/10/24.
//  Copyright © 2017年 takecx. All rights reserved.
//

import Foundation
import CoreLocation

class Beacon: NSObject, CLLocationManagerDelegate {
    
    var myLocationManager:CLLocationManager!
    var myBeaconRegion:CLBeaconRegion!
    var myIds: NSMutableArray!
    var myUuids: NSMutableArray!
    var beaconRegionArray = [CLBeaconRegion]()
    
    static let shard = Beacon()
    
    let UUIDList = [
        "CBAEF9E5-08DD-4D9C-831F-A61D1DFFFC8B"
    ]
    
    override init() {
        
        super.init()
        
        print("init")
        
        // ロケーションマネージャの作成.
        myLocationManager = CLLocationManager()
        
        // デリゲートを自身に設定.
        myLocationManager.delegate = self
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        // 取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 取得頻度の設定.(1mごとに位置情報取得)
        myLocationManager.distanceFilter = 1
        
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if status == CLAuthorizationStatus.notDetermined {
            print("didChangeAuthorizationStatus:\(status)");
            // まだ承認が得られていない場合は、認証ダイアログを表示
            myLocationManager.requestAlwaysAuthorization()
        }
        
        for i in (0 ..< UUIDList.count) {
            
            // BeaconのUUIDを設定.
            let uuid:NSUUID! = NSUUID(uuidString:UUIDList[i].lowercased())
            
            // BeaconのIfentifierを設定.
            let identifierStr:String = "identifier" + i.description
            
            // リージョンを作成.
            myBeaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID,  identifier: identifierStr)
            // majorId=0,minorId=0のビーコンのみ受信
            //myBeaconRegion = CLBeaconRegion(proximityUUID: uuid, major: CLBeaconMajorValue(0), minor: CLBeaconMinorValue(0), identifier: identifierStr)
            
            // ディスプレイがOffでもイベントが通知されるように設定(trueにするとディスプレイがOnの時だけ反応).
            myBeaconRegion.notifyEntryStateOnDisplay = false
            
            // 入域通知の設定.
            myBeaconRegion.notifyOnEntry = true
            
            // 退域通知の設定.
            myBeaconRegion.notifyOnExit = true
            
            beaconRegionArray.append(myBeaconRegion)
            
            myLocationManager.startMonitoring(for: myBeaconRegion)
        }
        
        // 配列をリセット
        myIds = NSMutableArray()
        myUuids = NSMutableArray()
    }
    
    /*
     (Delegate) 認証のステータスがかわったら呼び出される.
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("didChangeAuthorizationStatus");
        
        // 認証のステータスをログで表示
        var statusStr = "";
        switch (status) {
        case .notDetermined:
            statusStr = "NotDetermined"
            break
        case .restricted:
            statusStr = "Restricted"
            break
        case .denied:
            statusStr = "Denied"
            break
        case .authorizedAlways:
            statusStr = "AuthorizedAlways"
        case .authorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
            for region in beaconRegionArray {
                manager.startMonitoring(for: region)
                manager.startRangingBeacons(in: region)
            }
        }
        print(" CLAuthorizationStatus: \(statusStr)")
        
    }
    
    /*
     STEP2(Delegate): LocationManagerがモニタリングを開始したというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        print("didStartMonitoringForRegion");
        
        // STEP3: この時点でビーコンがすでにRegion内に入っている可能性があるので、その問い合わせを行う
        // (Delegate didDetermineStateが呼ばれる: STEP4)
        manager.requestState(for: region);
    }
    
    /*
     STEP4(Delegate): 現在リージョン内にいるかどうかの通知を受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        print("locationManager: didDetermineState \(state)")
        
        switch (state) {
            
        case .inside: // リージョン内にいる
            print("CLRegionStateInside:");
            
            // STEP5: すでに入っている場合は、そのままRangingをスタートさせる
            // (Delegate didRangeBeacons: STEP6)
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            break;
            
        case .outside:
            print("CLRegionStateOutside:")
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
            break;
            
        case .unknown:
            print("CLRegionStateUnknown:")
        // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
        default:
            
            break;
            
        }
    }
    
    /*
     STEP6(Delegate): ビーコンがリージョン内に入り、その中のビーコンをNSArrayで渡される.
     */
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        
        // 配列をリセット
        myIds = NSMutableArray()
        myUuids = NSMutableArray()
        
        // 範囲内で検知されたビーコンはこのbeaconsにCLBeaconオブジェクトとして格納される
        // rangingが開始されると１秒毎に呼ばれるため、beaconがある場合のみ処理をするようにすること.
        if(beacons.count > 0){
            
            // STEP7: 発見したBeaconの数だけLoopをまわす
            for i in (0 ..< beacons.count) {
                
                let beacon = beacons[i]
                
                let beaconUUID = beacon.proximityUUID;
                let minorID = beacon.minor;
                let majorID = beacon.major;
                let rssi = beacon.rssi;
                
                print("UUID: \(beaconUUID.uuidString)");
                print("minorID: \(minorID)");
                print("majorID: \(majorID)");
                print("RSSI: \(rssi)");
                
                var proximity = ""
                
                switch (beacon.proximity) {
                    
                case CLProximity.unknown :
                    print("Proximity: Unknown");
                    proximity = "Unknown"
                    break
                    
                case CLProximity.far:
                    print("Proximity: Far");
                    proximity = "Far"
                    break
                    
                case CLProximity.near:
                    print("Proximity: Near");
                    proximity = "Near"
                    break
                    
                case CLProximity.immediate:
                    print("Proximity: Immediate");
                    proximity = "Immediate"
                    break
                }
                
                let myBeaconId = "MajorId: \(majorID) MinorId: \(minorID)  UUID:\(beaconUUID) Proximity:\(proximity)"
                myIds.add(myBeaconId)
                myUuids.add(beaconUUID.uuidString)
                
                // 通知してみる
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "beaconReceive"), object: self)
            }
        }
    }
    
    /*
     (Delegate) リージョン内に入ったというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion");
        
        // Rangingを始める
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        
    }
    
    /*
     (Delegate) リージョンから出たというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NSLog("didExitRegion");
        
        // Rangingを停止する
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
}
