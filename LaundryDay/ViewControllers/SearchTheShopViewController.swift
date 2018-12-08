//
//  SearchTheShopViewController.swift
//  
//
//  Created by MBP03 on 2018. 7. 31..
//

import UIKit

class SearchTheShopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMLParserDelegate{

    
    @IBOutlet var ShopList: UITableView!
   // @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var queryText: UITextField!
    
    //@IBOutlet var searchingButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ShopList.dataSource = self
        ShopList.delegate = self
        
        navigationController?.navigationBar.setBackgroundImage(UIColor(red: 72/255, green: 199/255, blue: 149/255, alpha: 1).as1ptImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = false
        
        /*
        let button = UIButton(type: UIButtonType.system)
        button.frame = CGRect(x: 50, y:100, width:150, height:30)
        button.setTitle("검색", for: UIControlState.normal)
        self.view.addSubview(button)
        
        button.addTarget(self, action: #selector(onSearch(_:)), for: .touchUpInside)
        
        */
        //searchingButton.isEnabled = false
        
        
        // Do any additional setup after loading the view.
    }
    
    
    //ClientID
    //w1PKeXUIDhM6E2GqUmgR
    //ClientSecret
    //JF1pS2IjGb
    
    //https://openapi.naver.com/v1//v1/search/local.xml?query=SHOPNAME
    //https://openapi.naver.com/v1/search/local.xml?query=%EC%A3%BC%EC%8B%9D&display=10&start=1&sort=random
    
    @IBAction func onSearch(_Sender: AnyObject) {
        list.removeAll()
        if (queryText.text == "" ) {
            print("내용없음")
            return
        }
        print("실행됨")
        let urlString = "https://openapi.naver.com/v1/search/local.xml?query=" + queryText.text! + " 세탁"
        //URL 인코딩 반드시 해줄 것! (특수문자나 한글일 경우) : 인코딩을 해서 보내면 디코딩해서 해석하고 자료를 보내준다.
        let urlwithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: urlwithPercentEscapes!)
        
        var request = URLRequest(url: url!)
        request.addValue("application/xml; charset=uf-8", forHTTPHeaderField: "Content-Type")
        //네이버에서만 넣어주어야 하는 헤더 정보
        request.addValue("w1PKeXUIDhM6E2GqUmgR", forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue("JF1pS2IjGb", forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else{
                print(error)
                return
            }
            guard let data = data else {
                print("Data is Empty")
                return
            }
            
            //수신한 데이터 출력
            print(String(data: data, encoding: String.Encoding.utf8))
            
            self.item?.title = ""
            self.item?.roadAddress = ""
            //self.item?.telephone = ""
            //self.item?.mapx = 0.0
            //self.item?.mapy = 0.0
            
            //Parsel the XML
            let parser = XMLParser(data: Data(data))
            parser.delegate = self
            let success:Bool = parser.parse()
            if success{
                print("parse success!")
                print(self.strXMLData)
                DispatchQueue.main.async {
                    self.ShopList.reloadData()
                }
                
                //  IblNameData.text=strXMLData
            } else {
                print("parse failure!")
            }
            
            //let json = try! JSONSerialization.jsonObject(with: data, options: [])
            //print(json)
        }
        task.resume()
        

    }
    
    
    //XML delegate
    var currentElement : String? = ""
    var strXMLData : String? = ""
    var item : LaundryShop? = nil
    
    //태그가 시작되는 시점에 호출
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement=elementName;
        if (elementName == "item") {
            item=LaundryShop()
            item?.title = ""
            item?.roadAddress = ""
            //item?.telephone = ""
            //item?.description = ""
            //item?.mapx = 0.0
            //item?.mapy = 0.0
        }
    }
    
    //태그가 끝나느 시점에 호출
    //아이템 객체를 리스트라는 동적 배열에 집어넣기
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qname: String?) {
        currentElement="";
        
        if (elementName=="item"){
            self.list.append(self.item!)
         
        }
        
    }
    
    //태그와 태그 사이의 값 추출할때 호출 . 각 태그란 여기서 title, roadAddress, telephone
    func parser(_ parser : XMLParser, foundCharacters string: String){
        if (item != nil) {
            if (currentElement == "title"){
                item!.title! = item!.title! + string
            }else if (currentElement == "roadAddress"){
                self.item!.roadAddress! = self.item!.roadAddress! + string
            }
        }
    }
    
    func parser(_ parser : XMLParser, parseErrorOccured parseError: Error){
        //NSLog("failure error: %@", parseError)
    }
    
    var list = Array<LaundryShop>(); //여기까지가 서버와의 통신을 위한 작업이었음.
    
    //이제 이를 리스트에 집어넣고, 테이블 뷰로 출력하는 것.
    //테이블 뷰에 대한 3가지 delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count //아이템 갯수. 검색된 갯수만큼 출력하는 것
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    //특정 항목에 대한 셀 정보를 출력할 때. 각 몇번째 항목인지가 indexpath를 이용해 불러지고, indexpath안의 row로 ...
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ShopTableViewCell
        

        
        //몇번째 값을 가져다 쓰는지!
        let row = self.list[indexPath.row]
        
        //출력할때 html태그를 이용해 좀 더 formating된 형태로 출력하고자! 혹시 오류가 발생하면 그냥 뺴고 텍스트만 집어넣어라.
        /*
        do {
            let data = ("<H3><font color='red'>"+row.title!+"</<font></h3>").data(using:String.Encoding.utf8)
            let htmlAttrString = try NSAttributedString(data: data!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
            title?.attributedText = htmlAttrString
        } catch {
            print("An error occured")
            title?.text = row.title!
        }*/
        cell.laundryShop = row
        //telephone?.text = row.telephone!

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("select %d", indexPath.row)
    }
    


    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
