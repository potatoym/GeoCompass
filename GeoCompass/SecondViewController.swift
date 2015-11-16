//
//  SecondViewController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/9/3.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit
import CoreData


class SecondViewController:UITableViewController,UITabBarControllerDelegate,NSFetchedResultsControllerDelegate {
    let cdControl = NewsCoreDataController();
    var managedObjectContext: NSManagedObjectContext?
    //获取数据的控制器
    var addObjectContext: NSManagedObjectContext!
    var delegate: SecondViewController!
    
    var fetchedResultsController: NSFetchedResultsController?
    var rightBarButtonItem: UIBarButtonItem?
    var dateFormatter = NSDateFormatter()
    
    var segmentedControlChange = false;
    
    var dir:String = ""
    var Date:NSDate = NSDate();
    
    //输出用
    var needExport:[NSIndexPath]=[]
    var needExportBool:Bool = false
    var exportButton:UIBarButtonItem{
        return UIBarButtonItem(title:"输出", style:.Done, target: self, action: "exportAction:")
    }
    func exportAction(exportBarButton:UIBarButtonItem){
        NSLog("exportAction")
        needExportBool = true
        self.navigationItem.rightBarButtonItem = self.isExportButton
    }
    var isExportButton:UIBarButtonItem{
        return UIBarButtonItem(title:"完成", style:.Done, target: self, action: "isEportAction:")
    }
    func isExportAction(exportBarButton:UIBarButtonItem){
        NSLog("isExportAction")
        dir = NSHomeDirectory()+"/Documents/"+dateFormatter.stringFromDate(Date)+" 表格数据输出"
        var id:[String] = [],time:[String] = [],adr:[String] = []
        var strike:[String] = [] , dipdir:[String] = [] , dip:[String] = [];
        var pitch:[String] = [] , plusyn:[String] = [] , pluang:[String] = []; //pitch、plunging syncline and plunge angle
        var lat:[String] = [] , lon:[String] = [] , hight:[String] = [] , locError:[String] = [] , hightError:[String] = [] , magError:[String] = [] ;
        if needExport.count != 0 {
        if segmentedControl.selectedSegmentIndex == 0 {
            for (var i=0;i < needExport.count;i++) {
            let surfacedata = self.fetchedResultsController?.objectAtIndexPath(needExport[i]) as! SurfaceData
            id.append("\(surfacedata.id)")
            time.append(dateFormatter.stringFromDate(surfacedata.timeS))
            adr.append(surfacedata.adrS)
            strike.append("\(surfacedata.strikeS)")
            dipdir.append("\(surfacedata.dipdirS)")
            dip.append("\(surfacedata.dipS)");
            var R = transloc(surfacedata.latS as Double);
            lat.append("\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".4") + "\"")
            R = transloc(surfacedata.lonS as Double);
            lon.append("\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".4") + "\"")
            hight.append("\(surfacedata.hightS)")
            locError.append("\(surfacedata.locErrorS)")
            hightError.append("\(surfacedata.hightErrorS)")
            magError.append("\(surfacedata.magErrorS)")
            }
            var info = ""
            let title = "ID,时间,地址,走向,倾向,倾角,纬度,经度,高程,经纬误差,高程误差,磁偏角\n"
            info += title
            for (var i=0;i < needExport.count;i++) {
                info += (id[i]+",")
                info += (time[i]+",")
                info += (adr[i]+",")
                info += (strike[i]+",")
                info += (dipdir[i]+",")
                info += (dip[i]+",")
                info += (lat[i]+",")
                info += (lon[i]+",")
                info += (hight[i]+",")
                info += (locError[i]+",")
                info += (hightError[i]+",")
                info += (magError[i]+"\n")
            }
            do{try info.writeToFile(dir, atomically: true, encoding: NSUTF8StringEncoding)}catch let error as NSError{
                if error != 0 {NSLog("Unsolved error \(error)")}
            }
        }
        if segmentedControl.selectedSegmentIndex == 1 {
            for (var i=0;i < needExport.count;i++) {
            let linedata = self.fetchedResultsController?.objectAtIndexPath(needExport[i]) as! LineData
            id.append("\(linedata.id)")
            time.append(dateFormatter.stringFromDate(linedata.timeS))
            adr.append(linedata.adrS)
            strike.append("\(linedata.strikeS)")
            pitch.append("\(linedata.pitchS)")
            plusyn.append("\(linedata.plusynS)")
            pluang.append("\(linedata.pluangS)"); //pitch、plunging syncline and plunge angle
            var R = transloc(linedata.latS as Double);
            lat.append("\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".4") + "\"")
            R = transloc(linedata.lonS as Double);
            lon.append("\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".4") + "\"")
            hight.append("\(linedata.hightS)")
            locError.append("\(linedata.locErrorS)")
            hightError.append("\(linedata.hightErrorS)")
            magError.append("\(linedata.magErrorS)")
                }
            var info = ""
            let title = "ID,时间,地址,走向,侧俯角,倾伏向,倾俯角,纬度,经度,高程,经纬误差,高程误差,磁偏角\n"
            info += title
            for (var i=0;i < needExport.count;i++) {
                info += (id[i]+",")
                info += (time[i]+",")
                info += (adr[i]+",")
                info += (strike[i]+",")
                info += (pitch[i]+",")
                info += (plusyn[i]+",")
                info += (pluang[i]+",")
                info += (lat[i]+",")
                info += (lon[i]+",")
                info += (hight[i]+",")
                info += (locError[i]+",")
                info += (hightError[i]+",")
                info += (magError[i]+"\n")
            }
            do{try info.writeToFile(dir, atomically: true, encoding: NSUTF8StringEncoding)}catch let error as NSError{
                if error != 0 {NSLog("Unsolved error \(error)")}
            }
        }
      }
        else {self.navigationItem.rightBarButtonItem = self.exportButton;needExportBool = false;return}
        needExportBool = false
    }
    func transloc(a:Double)->(b:Int,c:Int,d:Double){
        var b = 0,c = 0,d = 0.0,last1 = 0.0,last2 = 0.0;
        last1 = a-Double(Int(a));
        b = Int(a);
        last2 = (last1*60)-Double(Int(last1*60));
        c = Int(last1*60);
        d = last2*60;
        return (b,c,d);
    }
    
    //cell相关
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if needExportBool == false {self.performSegueWithIdentifier("Detail", sender: self)}
        else {
        let cellView:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if cellView.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator{
            cellView.accessoryType=UITableViewCellAccessoryType.Checkmark
            needExport.append(indexPath)
        }
        else {
            cellView.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator;
            needExport.removeAtIndex(indexPath.row)
            }
        }
    }

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func indexChange(sender: UISegmentedControl) {
        var error: NSError? = nil
        segmentedControlChange = true;
        do {
            try self.initFetchedResultsController().performFetch()
        } catch let error1 as NSError {
            error = error1
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //为导航栏左边按钮设置编辑按钮
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.editButtonItem().title = "编辑"
        self.navigationItem.rightBarButtonItem = self.exportButton

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "历史数据", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        //执行获取数据，并处理异常
        var error: NSError? = nil
        do {
            try self.initFetchedResultsController().performFetch()
        } catch let error1 as NSError {
            error = error1
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //设置单元格的信息
    func setCellInfo(cell: UITableViewCell, indexPath: NSIndexPath) {
        dateFormatter.dateFormat = "yyyy-MM-dd HH时mm分"
        if segmentedControl.selectedSegmentIndex == 0 {
            let surfacedata = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! SurfaceData
            cell.textLabel!.text = dateFormatter.stringFromDate(surfacedata.timeS) + " 数据"
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            let linedata = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! LineData
            cell.textLabel!.text = dateFormatter.stringFromDate(linedata.timeS) + " 数据"
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //分组数量
        return self.fetchedResultsController!.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //每个分组的数据数量
        let section = self.fetchedResultsController!.sections![section]
        return section.numberOfObjects
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        // 为列表Cell赋值
        self.setCellInfo(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //分组表头显示
        return self.fetchedResultsController!.sections![section].name
    }
    

    // 自定义编辑单元格时的动作，可编辑样式包括UITableViewCellEditingStyleInsert（插入）、UITableViewCellEditingStyleDelete（删除）。
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //删除sqlite库中对应的数据
            let context = self.fetchedResultsController?.managedObjectContext
            context!.deleteObject(self.fetchedResultsController?.objectAtIndexPath(indexPath) as! NSManagedObject)
            //删除后要进行保存
            do{ try context?.save() }
            catch let error as NSError {
            if error != 0 {
                NSLog("Unresolved error \(error), \(error.userInfo)")
                abort()
            }}
            }
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // 移动单元格时不要重新排序
        return false
    }
    
    //编辑状态影藏右侧按钮
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if (editing) {
            self.editButtonItem().title = "完成"
            self.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
            self.navigationItem.rightBarButtonItem = nil;
        }
        else {
            self.editButtonItem().title = "编辑"
            self.navigationItem.rightBarButtonItem = self.exportButton
        }
        
    }
    // MARK: - NSFetchedResultsController delegate methods to respond to additions, removals and so on.
    
    //初始化获取数据的控制器
    func initFetchedResultsController() ->NSFetchedResultsController
    {
        var entityName = "SurfaceData"
        NSLog("===initFetchedResultsController===")
        if (self.fetchedResultsController != nil && segmentedControlChange == false) {
            NSLog("===1===")
            return self.fetchedResultsController!
        }
        else if segmentedControlChange == true {
            segmentedControlChange = false;
        }
        NSLog("===2===")
        // 创建一个获取数据的实例，用来查询实体
        let fetchRequest = NSFetchRequest()
        if segmentedControl.selectedSegmentIndex == 0 {
            entityName = "SurfaceData"
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            entityName = "LineData"
        }
        let entity = cdControl.EntityDescription(entityName)
        fetchRequest.entity = entity
        
        // 创建排序规则
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let authorDescriptor = NSSortDescriptor(key: "timeS", ascending: false)
        let titleDescriptor = NSSortDescriptor(key: "adrS", ascending: true)
        let sortDescriptors = [authorDescriptor, titleDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // 创建获取数据的控制器，将section的name设置为author，可以直接用于tableViewSourceData
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cdControl.cdh.managedObjectContext, sectionNameKeyPath: "adrS", cacheName: "Root")
        fetchedResultsController.delegate = self
        self.fetchedResultsController = fetchedResultsController
        return fetchedResultsController
    }
    
    //通知控制器即将开始处理一个或多个的单元格变化，包括添加、删除、移动或更新。在这里处理变化时对tableView的影响，例如删除sqlite数据时同时要删除tableView中对应的单元格
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        NSLog("==didChangeObject=="+type.rawValue.description)
        switch(type) {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Update:
            self.setCellInfo(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    //通知控制器即将开始处理一个或多个的分组变化，包括添加、删除、移动或更新。
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        NSLog("==didChangeSection=="+type.rawValue.description)
        switch(type) {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Update:
            break
        case .Move:
            break
        }
    }
    
    //通知控制器即将有变化
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        //tableView启动变更，需要endUpdates来结束变更，类似于一个事务，统一做变化处理
        self.tableView.beginUpdates()
    }
    
    //通知控制器变化完成
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
   
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //明细查询页面
        if (segue.identifier == "Detail") {
            NSLog("Detail go")
            //将所选择的当前数据赋值给所打开页面的控制器
            let secondViewDetailController = segue.destinationViewController as! SecondViewDetailController
            let currentRow = tableView.indexPathForSelectedRow
            if segmentedControl.selectedSegmentIndex == 0 {
                let surfacedata = self.fetchedResultsController?.objectAtIndexPath(currentRow!)as! SurfaceData
                secondViewDetailController.surfacedata = surfacedata
                secondViewDetailController.nowData = "surfacedata"}
            else if segmentedControl.selectedSegmentIndex == 1 {
                let linedata = self.fetchedResultsController?.objectAtIndexPath(currentRow!)as! LineData
                secondViewDetailController.linedata = linedata
                secondViewDetailController.nowData = "linedata"}
        }
    }

}

