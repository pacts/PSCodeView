# PSCodeView
  仿照微信支付宝密码输入控件
 let width = UIScreen.main.bounds.width

        let rect = PSCodeView()
        rect.frame = CGRect(x: 20, y: 80, width: width - 40, height: 50)
        rect.isSecureTextEntry = true
        self.view.addSubview(rect)
        
        let line = PSCodeView()
        line.type = .line
        line.length = 4
        line.keyboardType = .asciiCapable
        line.frame = CGRect(x: 20, y: 150, width: width - 40, height: 50)
        self.view.addSubview(line)
        
        let circle = PSCodeView()
        circle.type = .circle
        circle.textColor = .red
        circle.length = 4
        circle.selectedColor = .orange
        circle.frame = CGRect(x: 20, y: 220, width: width - 40, height: 50)
        self.view.addSubview(circle)
