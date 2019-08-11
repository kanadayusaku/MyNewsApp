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
    
    //webview
    @IBOutlet weak var WebView: WKWebView!
    //
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
        
        //parserとの接続
        parser.delegate = self

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
    }
    

    func parseUrl() {
        let urlToSend :URL = URL(string: url)!
        parser = XMLParser(contentsOf: urlToSend)!
        articles = []
        //解析の実行
        parser.parse()
        //reload the tableView
        tableView.reloadData()
    }
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)
        -> CGFloat {
            return 100
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
     
        cell.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        
        //記事テキストサイズとフォント
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cell.textLabel?.textColor = UIColor.black
        
        //記事URLのサイズとフォント
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.detailTextLabel?.textColor = UIColor.gray
        
        return cell
    }
    //セルをタップした時の処理（未）
    
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
