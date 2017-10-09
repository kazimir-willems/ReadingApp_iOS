//
//  ViewController.swift
//  reading
//
//  Created by JinYongHao on 01/09/2017.
//  Copyright © 2017 Johan Friso. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var txtSpeed: UITextField!
    @IBOutlet weak var txtFont: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    //@IBOutlet weak var lblReadingMode: UILabel!
    //@IBOutlet weak var btnReadingMode: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var btnTehillim: UIButton!
    @IBOutlet weak var constraintWidth: NSLayoutConstraint!
    
    var nSpeed:CGFloat = 10
    var nFontSize:Int = 18
    var text:String = ""
    var textWithout:String = "" // text without new line break
    var bPlay:Bool = false
    var startTime:CFAbsoluteTime!
    var processTime:Int = 0
    var bestTime:Int = 0 // Shortest time to read
    var nType:Int = 0 // Type of Text
    //var nMode = 0 // Reading Mode. 0 - Horizontal, 1 - Vertical
    var iBlock = 0 // position of block among several splitted text, in case of size of text is larger than 1000 charaters
    var nTotalBlocks = 0
    var nBlockSize = 300
    var widthOrg:CGFloat = 0
    var heightOrg:CGFloat = 0
    //let WIDTH_LIMIT:CGFloat = 8000
    @IBOutlet weak var constant: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadConfig() // load Speed, Font Size and Reading Mode
        
        // display status text on status label
        updateStatus(bElpasedZero: true)
        
        // display speed and font size, and set font size to nFontSize
        txtSpeed.text = String(Int(nSpeed))
        txtFont.text = String(nFontSize)
        changeFontSize(fontsize: nFontSize)
        
        displayTextByReadingMode()
        
        heightOrg = txtView.frame.size.height
        widthOrg = scrollView.frame.size.width
    }
    
    override func viewDidAppear(_ animated: Bool) {
        btnTehillim.sendActions(for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickBtnSpeedUp(_ sender: Any) {
        if (nSpeed < 50) {
            nSpeed = nSpeed + 1
            txtSpeed.text = String(Int(nSpeed))
            saveConfig()
        }
    }
    
    @IBAction func onClickBtnSpeedDown(_ sender: Any) {
        if (nSpeed > 5) {
            nSpeed = nSpeed - 1
            txtSpeed.text = String(Int(nSpeed))
            saveConfig()
        }
    }

    @IBAction func onClickBtnFontUp(_ sender: Any) {
        if (nFontSize >= 8 && nFontSize < 50) {
            nFontSize = nFontSize + 1
            txtFont.text = String(nFontSize)
            changeFontSize(fontsize: nFontSize)
            updateStatus(bElpasedZero: false)
            saveConfig()
        }
    }
    
    @IBAction func onClickBtnFontDown(_ sender: Any) {
        if (nFontSize > 8 && nFontSize <= 50) {
            nFontSize = nFontSize - 1
            txtFont.text = String(nFontSize)
            changeFontSize(fontsize: nFontSize)
            updateStatus(bElpasedZero: false)
            saveConfig()
        }
    }
    
    @IBAction func onClickBtnTehillm(_ sender: Any) {
        btnPause.sendActions(for: .touchUpInside)
        
        readFile(filename: "Tehillim", bAlignRight: true)
        nType = 0;
        updateStatus(bElpasedZero: true)
        displayTextByReadingMode()
    }
    
    @IBAction func onClickBtnTikkun(_ sender: Any) {
        btnPause.sendActions(for: .touchUpInside)
        
        readFile(filename: "Hatikun", bAlignRight: true)
        nType = 1;
        updateStatus(bElpasedZero: true)
        displayTextByReadingMode()
    }
    
    @IBAction func onClickParshat(_ sender: Any) {
        btnPause.sendActions(for: .touchUpInside)
        
        readFile(filename: "Parashat", bAlignRight: true)
        nType = 2;
        updateStatus(bElpasedZero: true)
        displayTextByReadingMode()
    }
    
    @IBAction func onClickPerek(_ sender: Any) {
        btnPause.sendActions(for: .touchUpInside)
        
        readFile(filename: "PerekShira", bAlignRight: true)
        nType = 3;
        updateStatus(bElpasedZero: true)
        displayTextByReadingMode()
    }
    
    @IBAction func onClickBtnAbount(_ sender: Any) {
        btnPause.sendActions(for: .touchUpInside)
        
        readFile(filename: "About", bAlignRight: false)
        nType = 4;
        updateStatus(bElpasedZero: true)
        displayTextByReadingMode()
    }
    
    @IBAction func onPlay(_ sender: Any) {
        bPlay = true
        btnPlay.isEnabled = false
        btnPlay.alpha = 0.5
        //btnReadingMode.isEnabled = false
        //btnReadingMode.alpha = 0.5
        startTime = CFAbsoluteTimeGetCurrent()
        scrollText()
    }
    
    @IBAction func onPause(_ sender: Any) {
        bPlay = false
        btnPlay.isEnabled = true
        btnPlay.alpha = 1.0
        //btnReadingMode.isEnabled = true
        //btnReadingMode.alpha = 1.0
    }
    
    
    // Read a file and store it in variable "text"
    func readFile(filename: String, bAlignRight: Bool) {
        let path:String = Bundle.main.path(forResource: filename, ofType: "txt")!
        let url:URL = URL(fileURLWithPath: path)
        text = try! String(contentsOf: url, encoding: String.Encoding.utf8)
        textWithout = text.replacingOccurrences(of: "\r\n", with: " ")
        iBlock = 0
        nTotalBlocks = textWithout.characters.count / nBlockSize + 1
    }
    
    @IBAction func onChangeSpeedText(_ sender: Any) {
        let speed = txtSpeed.text
        if (speed == "" || Int(speed!) == nil) {
            return
        }
        
        nSpeed = CGFloat(Int(speed!)!)
    }
    
    @IBAction func onChangeTextEdit(_ sender: Any) {
        let font = txtFont.text
        if (font == "" || Int(font!) == nil) {
            return
        }
        
        nSpeed = CGFloat(Int(font!)!)
    }
    
    @IBOutlet weak var onChangeFontText: UITextField!
    func changeFontSize(fontsize: Int) {
        txtView.font = UIFont(name: (txtView.font?.fontName)!, size: CGFloat(fontsize))
        updateStatus(bElpasedZero: false)
    }
    
    func scrollText() {
        txtView.isScrollEnabled = true
        
        
        if (!bPlay) {
            return
        }
        
        if (self.txtView.contentOffset.y + txtView.frame.size.height >=
            self.txtView.contentSize.height) {
            let diffTime:CFAbsoluteTime = CFAbsoluteTimeGetCurrent() - startTime
            processTime = Int(diffTime.magnitude)
            
            if (bestTime == 0 || processTime < bestTime) {
                bestTime = processTime
                saveBestTime(type: nType)
            }
            
            updateStatus(bElpasedZero: false)
            bPlay = false
            
            // Play & ReadingMode Button is enabled
            btnPlay.isEnabled = true
            btnPlay.alpha = 1.0
            
            return
        }
        
        // scroll animation
        UIView.animate(withDuration:0,
                       delay: 0.02,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.txtView.contentOffset.y =
                            self.txtView.contentOffset.y + self.nSpeed / 2},
                       completion: { finished in
                        DispatchQueue.main.async {
                            self.scrollText()
                        }
        })
    }
    
    // display status on status label
    func updateStatus(bElpasedZero :Bool) {
        getBestTime(type: nType)
        
        if (bElpasedZero) {
            processTime = 0
        }
        lblStatus.text = String(format: "Speed: %d\nTime: %ds\nBest: %ds",
                                Int(nSpeed),
                                processTime,
                                bestTime)
    }
    
    func moveTextPositionToTop() {
        self.txtView.contentOffset = CGPoint.zero
    }
    
    func saveBestTime(type:Int) {
        let defaults = UserDefaults.standard
        
        switch (type) {
        case 0:
            defaults.set(bestTime, forKey: "Tehillim")
            break;
        case 1:
            defaults.set(bestTime, forKey: "Hatikun")
            break;
        case 2:
            defaults.set(bestTime, forKey: "Parashat")
            break;
        case 3:
            defaults.set(bestTime, forKey: "Perek")
            break;
        case 4:
            defaults.set(bestTime, forKey: "About")
            break;
        default:
            break;
        }
    }
    
    // get best time, but don't display
    func getBestTime(type:Int) {
        let defaults = UserDefaults.standard
        
        if (nSpeed <= 0) {
            nSpeed = 10
        }
        if (nFontSize <= 0) {
            nFontSize = 18
        }
        
        switch (type) {
        case 0:
            bestTime = defaults.integer(forKey: "Tehillim")
            break;
        case 1:
            bestTime = defaults.integer(forKey: "Hatikun")
            break;
        case 2:
            bestTime = defaults.integer(forKey: "Parashat")
            break;
        case 3:
            bestTime = defaults.integer(forKey: "Perek")
            break;
        case 4:
            bestTime = defaults.integer(forKey: "About")
            break;
        default:
            break;
        }
    }
    
    func loadConfig() {
        let defaults = UserDefaults.standard
        
        nSpeed = CGFloat(defaults.integer(forKey: "Speed"))
        if (nSpeed == 0) {
            nSpeed = 10
        }
        nFontSize = defaults.integer(forKey: "Font")
        if (nFontSize == 0) {
            nFontSize = 18
        }
        //nMode = defaults.integer(forKey: "Mode")
    }
    
    func saveConfig() {
        let defaults = UserDefaults.standard
        
        defaults.set(nSpeed, forKey: "Speed")
        defaults.set(nFontSize, forKey: "Font")
        //defaults.set(nMode, forKey: "Mode")
    }
    
    func displayTextByReadingMode() {
        txtView.text = self.text
        txtView.textContainer.maximumNumberOfLines = 0
        txtView.contentInset.top = 0
        if (nType == 4) {
            txtView.textAlignment = .left
            txtView.semanticContentAttribute = .forceLeftToRight
        } else {
            txtView.textAlignment = .right
            txtView.semanticContentAttribute = .forceRightToLeft
        }

        txtView.scrollRangeToVisible(NSRange(location:0, length:0))
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
    }
    
    func hasToLoadText() -> Bool {
        if (iBlock >= nTotalBlocks - 1) {
            return false
        }
        
        if (nType == 4 &&
            self.scrollView.contentOffset.x * 1.25 + widthOrg >=
            self.scrollView.contentSize.width) {
            return true
        }
        let diff = scrollView.contentOffset.x - self.scrollView.contentOffset.x
        if (nType != 4 && diff <= 3 * widthOrg) {
            return true
        }
        
        return false
    }
}

