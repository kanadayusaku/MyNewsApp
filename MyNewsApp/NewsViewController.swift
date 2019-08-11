//
//  NewsViewController.swift
//  MyNewsApp
//
//  Created by 金田祐作 on 2019/08/11.
//  Copyright © 2019 金田祐作. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import WebKit

class NewsViewController: UIViewController,IndicatorInfoProvider,UITableViewDataSource, UITableViewDelegate,WKNavigationDelegate,XMLParserDelegate {
    
    //tableviewのインスタンスを取得
    var tableView: UITableView = UITableView()

    //XMLParserのインスタンスを取得
    var parser = XMLParser()
    
    //記事情報の配列の入れ物
    //var articlrd = NSMutableDictionary()
    var articles:[Any] = []
    
    //XML Fileに解析をかけた情報
    var elements = NSMutableDictionary()
    //information of XMLFile tag
    var element: String = ""
    //information of XMLTitle tag
    var titleString: String = ""
    //information of XMLLink tag
    var linkString: String = ""
    
    //webview
    @IBOutlet weak var WebView: WKWebView!
    //Toolbar
    @IBOutlet weak var toolBar: UIToolbar!
    
    //urlを受け取る
    var url: String = ""
    //itemInfoを受け取る
    var itemInfo: IndicatorInfo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //デリゲートとの接続
        tableView.delegate = self
        tableView.dataSource = self
    
        //navigationDelegateとの接続
        WebView.navigationDelegate = self
        
        //tableviewのサイズを確定
        tableView.frame = CGRect(x: 0, y: 50, width: self.view.frame.width,
                                 height: self.view.frame.height - 50.0)
        //tableviewをviewに追加
        self.view.addSubview(tableView)
        
        //最初は隠す（tableviewが表示されるのを邪魔しないように）
        WebView.isHidden = true
        toolBar.isHidden = true
        
        parseUrl()
    }
    

    func parseUrl() {
        let urlToSend :URL = URL(string: url)!
        parser = XMLParser(contentsOf: urlToSend)!
        articles = []
        //parserとの接続
        parser.delegate = self
        //解析の実行
        parser.parse()
        //reload the tableView
        tableView.reloadData()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    //elementNameにタグの名前が入ってくるのでelementに代入
        element = elementName
        //エレメントに入ってきたら
        if element == "item"{
            //初期化  [:]←辞書型の初期化
            elements = [:]
            titleString = ""
            linkString = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if element == "title" {
            titleString.append(string)
        } else if element == "link"{
            linkString.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if titleString != ""{
                elements.setObject(titleString, forKey: "title" as NSCopying)
            }
            if linkString != "" {
                elements.setObject(linkString, forKey: "link" as NSCopying)
            }
           //articleの中にelementsをい入れる
          articles.append(elements)
        }
    }
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)
        -> CGFloat {
            return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
     
        cell.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        
        //記事テキストサイズとフォント
      cell.textLabel?.text = (articles[indexPath.row] as AnyObject).value(forKey: "title") as? String
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cell.textLabel?.textColor = UIColor.black
        
        //記事URLのサイズとフォント
        cell.detailTextLabel?.text = (articles[indexPath.row] as AnyObject).value(forKey: "link") as? String
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.detailTextLabel?.textColor = UIColor.gray
        
        return cell
    }
    //セルをタップした時の処理（未）
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linkUrl = ((articles[indexPath.row]as
        AnyObject).value(forKey: "link") as?
        String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlStr =
        (linkUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        guard let url = URL(string: urlStr) else {
            return
        }
        let urlRequest = NSURLRequest(url: url)
        WebView.load(urlRequest as URLRequest)
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        tableView.isHidden = true
        //toolbarを表示する
        toolBar.isHidden = false
        //webviewを表示する
        webView.isHidden = false
    }
    
    @IBAction func cancel(_ sender: Any) {
    }
    
    @IBAction func nextPage(_ sender: Any) {
        WebView.goForward()
    }
    
    @IBAction func backPage(_ sender: Any) {
        WebView.goBack()
    }
    
    @IBAction func refreshPage(_ sender: Any) {
        WebView.reload()
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
