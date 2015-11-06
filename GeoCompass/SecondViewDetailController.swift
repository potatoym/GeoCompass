//
//  SecondViewDetailController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/4.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//
import UIKit



class SecondViewDetailController: UITableViewController{
    var surfacedata:SurfaceData!
    var lindata:LineData!
    var dateFormatter = NSDateFormatter()
    
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var detail1: UILabel!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var detail2: UILabel!
    @IBOutlet weak var title3: UILabel!
    @IBOutlet weak var detail3: UILabel!
    @IBOutlet weak var title4: UILabel!
    @IBOutlet weak var detail4: UILabel!
    @IBOutlet weak var title5: UILabel!
    @IBOutlet weak var detail5: UILabel!
    @IBOutlet weak var title6: UILabel!
    @IBOutlet weak var detail6: UILabel!
    @IBOutlet weak var title7: UILabel!
    @IBOutlet weak var detail7: UILabel!
    @IBOutlet weak var title8: UILabel!
    @IBOutlet weak var detail8: UILabel!
    @IBOutlet weak var title9: UILabel!
    @IBOutlet weak var detail9: UILabel!
    @IBOutlet weak var title10: UILabel!
    @IBOutlet weak var detail10: UILabel!
    @IBOutlet weak var title11: UILabel!
    @IBOutlet weak var detail11: UILabel!
    @IBOutlet weak var title12: UILabel!
    @IBOutlet weak var detail12: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("==viewDidLoad==")
        

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.editButtonItem().title = "编辑"

        
        //编辑的时候允许选择
        self.tableView.allowsSelectionDuringEditing = true
        
        //监听到NSCurrentLocaleDidChangeNotification时，即系统语言变化时触发的方法，与removeObserver是一对
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeChanged:", name: NSCurrentLocaleDidChangeNotification, object: nil)
    }
    
    deinit{
        NSLog("==deinit==")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSCurrentLocaleDidChangeNotification, object: nil)
    }
    
    /*
    The view controller must be first responder in order to be able to receive shake events for undo. It should resign first responder status when it disappears.指定是否可以时第一响应者，通俗来讲就是焦点
    */
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //view显示时设置焦点
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    //view销毁前取消焦点
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
    }
    
    //视图即将可见时调用，每次显示view就会调用
    override func viewWillAppear(animated: Bool) {
        NSLog("==viewWillAppear==")
        super.viewWillAppear(animated)
        
        //重载数据
        self.updateInterface()
        //改变右侧按钮状态
        self.updateRightBarButtonItemState()
    }

    //设置为编辑模式时调用
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        NSLog("==setEditing==\(editing)")
        
        self.navigationItem.setHidesBackButton(editing, animated: animated)
        
        //编辑状态时设置撤销管理器
        if(editing){
            self.editButtonItem().title = "完成"
            self.setUpundoManager()
        }else
            //非编辑状态时取消撤销管理器并保存数据
        {
            self.editButtonItem().title = "编辑"
            self.cleanUpUndoManager()
            var error: NSError? = nil
            if !self.surfacedata.managedObjectContext!.save(&error) {
                NSLog("Unresolved error \(error), \(error?.userInfo)")
                abort()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //更新数据
    func transloc(a:Double)->(b:Int,c:Int,d:Double){
        var b = 0,c = 0,d = 0.0,last1 = 0.0,last2 = 0.0;
        last1 = a-Double(Int(a));
        b = Int(a);
        last2 = (last1*60)-Double(Int(last1*60));
        c = Int(last1*60);
        d = last2*60;
        return (b,c,d);
    }
    
    func updateInterface() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm";
        
        self.title1.text = "时间"
        self.detail1.text = dateFormatter.stringFromDate(surfacedata.timeS)
        self.title2.text = "地址"
        self.detail2.text = self.surfacedata.adrS;
        self.title3.text = "走向"
        self.detail3.text = (self.surfacedata.strikeS as! Double).format(".2")+"°";
        self.title4.text = "倾向"
        self.detail4.text = (self.surfacedata.dipdirS as! Double).format(".2")+"°";
        self.title5.text = "倾角"
        self.detail5.text = (self.surfacedata.dipS as! Double).format(".2")+"°";
        self.title6.text = "纬度"
        var R = transloc(self.surfacedata.latS as! Double);
        self.detail6.text = "\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".4") + "\"";
        self.title7.text = "经度"
        R = transloc(self.surfacedata.lonS as! Double);
        self.detail7.text = "\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".4") + "\"";
        self.title8.text = "高程"
        self.detail8.text = (self.surfacedata.hightS as! Double).format(".2")+"m";
        self.title9.text = "经纬误差"
        self.detail9.text = "±"+(self.surfacedata.locErrorS as! Double).format(".1")+"m";
        self.title10.text = "高程误差"
        self.detail10.text = "±"+(self.surfacedata.hightErrorS as! Double).format(".1")+"m";
        self.title11.text = "磁偏角"
        self.detail11.text = (self.surfacedata.magErrorS as! Double).format(".2")+"°";
        self.title12.text = ""
        self.detail12.text = ""

        NSLog("===updateInterface===\(self.surfacedata.timeS)")
    }
    
    func updateRightBarButtonItemState() {
        NSLog("==updateRightBarButtonItemState==")
        // 如果实体对象在保存状态，则允许右侧按钮
        var error: NSError? = nil
        self.navigationItem.rightBarButtonItem?.enabled = self.surfacedata.validateForUpdate(&error)
    }
    
    // MARK: - Table view data source
    
    //点击编辑按钮时的row编辑样式，默认delete，row前有一个删除标记，这里用none，没有任何标记
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    //点击编辑按钮时row是否需要缩进，这里不需要
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    //在行将要选择的时候执行。通常，你可以使用这个方法来阻止选定特定的行。返回结果是选择的行
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if(self.editing){
            return indexPath
        }
        return nil
    }
    
    //在选择行后执行，这里是编辑状态选中一行时创建一个编辑页面
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(self.editing){
            self.performSegueWithIdentifier("ItemToEdit", sender: self)
        }
    }
    
    // MARK: - Undo support
    
    //设置撤回管理器
    func setUpundoManager() {
        if self.surfacedata.managedObjectContext?.undoManager == nil {
            self.surfacedata.managedObjectContext?.undoManager =  NSUndoManager()
            self.surfacedata.managedObjectContext?.undoManager?.levelsOfUndo = 13//撤销最大数
        }
        
        var bookUndoManager = self.surfacedata.managedObjectContext?.undoManager
        
        //监听撤回和取消撤回
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "undoManagerDidUndo:", name: NSUndoManagerDidUndoChangeNotification, object: bookUndoManager)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "undoManagerDidRedo:", name: NSUndoManagerDidRedoChangeNotification, object: bookUndoManager)
    }
    
    //取消撤回管理器
    func cleanUpUndoManager() {
        var bookUndoManager = self.surfacedata.managedObjectContext?.undoManager
        
        //移除撤回和取消撤回监听
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUndoManagerWillUndoChangeNotification, object: bookUndoManager)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUndoManagerWillRedoChangeNotification, object: bookUndoManager)
        
        //置空context的撤回管理器
        self.surfacedata.managedObjectContext?.undoManager = nil
    }
    
    //监听到撤回触发，重载数据和导航右侧按钮状态
    func undoManagerDidUndo(notification : NSNotification){
        NSLog("==undoManagerDidUndo==")
        //重载数据
        self.updateInterface()
        //改变右侧按钮状态
        self.updateRightBarButtonItemState()
    }
    
    //监听到取消撤回触发，重载数据和导航右侧按钮状态
    func undoManagerDidRedo(notification : NSNotification){
        NSLog("==undoManagerDidRedo==")
        //重载数据
        self.updateInterface()
        //改变右侧按钮状态
        self.updateRightBarButtonItemState()
    }
    

    
    // MARK: - Navigation
    
    //通过segue跳转前所做的工作
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "ItemToEdit"){
            var bookEditViewController = segue.destinationViewController as! SecondViewEditController
            
            bookEditViewController.editedObject = self.surfacedata
            //根据选择的不同行为编辑view赋不同的值
            switch(self.tableView.indexPathForSelectedRow()!.row) {
            case 0:
                break
            case 1:
                bookEditViewController.editedFieldKey = "timeS"
                bookEditViewController.editedFieldName = "时间"
            case 2:
                bookEditViewController.editedFieldKey = "adrS"
                bookEditViewController.editedFieldName = "地址"
            case 3:
                bookEditViewController.editedFieldKey = "strikeS"
                bookEditViewController.editedFieldName = "走向"
            default:
                break
            }
        }
    }
    
    // MARK: - Locale changes
    
    //监听到语言变化时，重载数据
    func localeChanged(notification : NSNotification) {
        NSLog("==localeChanged==")
        //重载数据
        self.updateInterface()
    }

}