# BeaconTest

BTN01の電波が受信できません  
(BComm -> ViewController.swift参照)

didStartMonitoringForは呼ばれますが、BTN01のボタンを押してもdidEnterRegionが発火しません。。。

imagesディレクトリ以下に必要かもしれない画像を入れています。  
・term_of_signal_LightBlue.PNG：LightBlueで設定したterm_of_signalの値  
・TxPower_LightBlue.PNG：LightBlueで設定したTxPowerの値  
・uuid_LightBlue.PNG：LightBlueで設定したuuidの値（この値がproximity UUIDでしょうか？）  
・uuidgen.png：Macのターミナルでuuidgenした結果  

【検証環境】  
・macOS Sierra ver.10.12.6  
・XCode Version 9.0 (9A235)  
・Apple iPhone6 (MG4F2J/A)  
・iOS バージョン 11.0.3 (15A432)  
