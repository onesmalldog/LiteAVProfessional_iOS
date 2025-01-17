//
//  MineRootView.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/6.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

class MineRootView: UIView {
    
    let viewModel : MineViewModel
    
    public weak var rootVC: MineViewController?
    
    init(viewModel: MineViewModel, frame: CGRect = .zero) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgView: UIImageView = {
        let bgView = UIImageView(frame: .zero)
        bgView.contentMode = .scaleAspectFill
        bgView.image = UIImage(named: "main_mine_headerbg")
        return bgView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Semibold", size: 18)
        label.textColor = .white
        label.text = .titleText
        return label
    }()
    
    lazy var backBtn: UIButton = {
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.sizeToFit()
        return backBtn
    }()
    
    lazy var userNameBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("USERID", for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Semibold", size: 18)
        btn.setImage(UIImage(named: "main_mine_edit"), for: .normal)
        return btn
    }()
    
    lazy var userIdLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = .white
        return label
    }()
    
    let versionTip: UILabel = {
        let tip = UILabel()
        tip.textAlignment = .center
        tip.font = UIFont.systemFont(ofSize: 14)
        tip.textColor = UIColor(hex: "525252")
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0.1.1"
        #if LIVE
        let sdvVersionStr = V2TXLivePremier.getSDKVersionStr()
        #else
        let sdvVersionStr = TXLiveBase.getSDKVersionStr() ?? "1.0.0"
        #endif
        tip.text = V2Localize("V2.Live.LinkMicNew.loginTitle")
        let versionStr: String = " v\(sdvVersionStr)(\(version))"
        tip.text = tip.text! + versionStr
        tip.adjustsFontSizeToFitWidth = true
        return tip
    }()
    
    let bottomTip: UILabel = {
        let tip = UILabel()
        tip.textAlignment = .center
        tip.font = UIFont.systemFont(ofSize: 14)
        tip.textColor = UIColor(hex: "525252")
        tip.text = V2Localize("V2.Live.LinkMicNew.appusetoshowfunc")
        tip.adjustsFontSizeToFitWidth = true
        return tip
    }()
    
    let headImageDiameter: CGFloat = 100
    
    lazy var headImageView: UIImageView = {
        let imageV = UIImageView(frame: .zero)
        imageV.contentMode = .scaleAspectFill
        imageV.layer.cornerRadius = headImageDiameter * 0.5
        imageV.clipsToBounds = true
        return imageV
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: .topRight, cornerRadii: CGSize(width: 20, height: 20))
    }
    
    @objc func backBtnClick() {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                viewController.navigationController?.popViewController(animated: true)
                return;
            }
        }
    }
    
    @objc func logoutBtnClick() {
        let alert:UIAlertController = UIAlertController(title: V2Localize("V2.Live.LinkMicNew.suretologout"), message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: V2Localize("V2.Live.LinkMicNew.cancel"), style: .cancel) { (action) in
        }
        let okAction = UIAlertAction(title: V2Localize("V2.Live.LinkMicNew.confirm"), style: .default) { (action) in
            ProfileManager.shared.removeLoginCache()
            AppUtils.shared.showLoginController()
            V2TIMManager.sharedInstance()?.logout({
                
            }, fail: { (Int32, _: String?) in
                
            })
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        if let rootVC = self.rootVC {
            rootVC.present(alert, animated: false, completion: nil)
        }
    }

    var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(containerView)
        containerView.addSubview(contentView)
        contentView.addSubview(userNameBtn)
        contentView.addSubview(userIdLabel)
        contentView.addSubview(tableView)
        containerView.addSubview(headImageView)
        addSubview(titleLabel)
        addSubview(backBtn)
        addSubview(bottomTip)
        addSubview(versionTip)
    }
    
    func activateConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kDeviceSafeTopHeight+20)
        }
        backBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.leading.equalToSuperview().offset(20)
        }
        bgView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(bgView.snp_width).multipliedBy(220.0/375.0)
        }
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp_bottom).offset(-32-headImageDiameter * 0.5)
            make.leading.trailing.bottom.equalToSuperview();
        }
        contentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(headImageDiameter * 0.5)
            make.leading.trailing.bottom.equalToSuperview()
        }
        userNameBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(headImageDiameter * 0.5);
            make.centerX.equalToSuperview();
        }
        userIdLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userNameBtn.snp_bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(userIdLabel.snp_bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        headImageView.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview();
            make.size.equalTo(CGSize(width: headImageDiameter, height: headImageDiameter));
        }
        bottomTip.snp.makeConstraints { (make) in
            make.bottomMargin.equalTo(self).offset(-12)
            make.leading.trailing.equalTo(self)
            make.height.equalTo(30)
        }
        versionTip.snp.makeConstraints { (make) in
            make.bottom.equalTo(bottomTip.snp.top).offset(-2)
            make.height.equalTo(12)
            make.leading.trailing.equalTo(self)
        }
    }
    
    func bindInteraction() {
        
        userNameBtn.addTarget(self, action: #selector(userIdBtnClick(btn:)), for: .touchUpInside)
        
        tableView.register(MineTableViewCell.self, forCellReuseIdentifier: "MineTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(headBtnClick))
        headImageView.addGestureRecognizer(tap)
        
        updateHeadImage()
        updateName()
        updateUserId()
    }
    
    func updateHeadImage() {
        if let user = viewModel.user {
            headImageView.sd_setImage(with: URL(string: user.avatar), placeholderImage: nil, options: .continueInBackground, completed: nil)
        }
    }
    
    func updateUserId() {
        if let user = viewModel.user {
            userIdLabel.text = "ID:\(user.userId)"
        }
    }
    
    func updateName() {
        if let user = viewModel.user {
            // replace title and image, then add spacing
            userNameBtn.setTitle(user.name, for: .normal)
            userNameBtn.sizeToFit()
            let totalWidth = userNameBtn.frame.width
            let imageWidth = userNameBtn.imageView!.frame.width
            let titleWidth = totalWidth - imageWidth
            let spacing = CGFloat(4)
            userNameBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth-spacing * 0.5, bottom: 0, right: imageWidth+spacing * 0.5)
            userNameBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleWidth+spacing * 0.5, bottom: 0, right: -titleWidth-spacing * 0.5)
            userNameBtn.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(headImageDiameter * 0.5);
                make.centerX.equalToSuperview();
                make.width.equalTo(totalWidth + spacing)
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        guard let superview = headImageView.superview else {
            return super.hitTest(point, with: event)
        }
        let rect = superview.convert(headImageView.frame, to: self)
        if rect.contains(point) {
            return headImageView
        }
        return super.hitTest(point, with: event)
    }
    
    @objc func userIdBtnClick(btn: UIButton) {
        let alert = MineUserIdEditView(viewModel: viewModel)
        (UIApplication.shared.windows.first ?? self).addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alert.layoutIfNeeded()
        alert.show()
        alert.didDismiss = { [weak self] in
            guard let `self` = self else { return }
            self.updateName()
        }
    }
    
    @objc func headBtnClick() {
        let model = TRTCAlertViewModel()
        let alert = TRTCAvatarListAlertView(viewModel: model)
        (UIApplication.shared.windows.first ?? self).addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alert.layoutIfNeeded()
        alert.show()
        alert.didClickConfirmBtn = { [weak self] in
            guard let `self` = self else { return }
            if let url = ProfileManager.shared.curUserModel?.avatar {
                self.headImageView.sd_setImage(with: URL(string: url), placeholderImage: nil, options: .continueInBackground, completed: nil)
            }
            ProfileManager.shared.synchronizUserInfo()
        }
        alert.willDismiss = { [weak self] in
            guard let `self` = self else { return }
            self.updateHeadImage()
        }
    }
}

extension MineRootView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableDataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MineTableViewCell", for: indexPath)
        if let scell = cell as? MineTableViewCell {
            let model = viewModel.tableDataSource[indexPath.row]
            if model.title == .logoutText {
                scell.detailImageView.isHidden = true
            }
            scell.model = model
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
extension MineRootView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.tableDataSource[indexPath.row]
        switch model.type {
        
        case .about:
            let vc = MineAboutViewController()
            vc.hidesBottomBarWhenPushed = true
            rootVC?.navigationController?.pushViewController(vc, animated: true)
            
        case .privacy:
            let vc = TRTCWebViewController(url: URL(string: "https://web.sdk.qcloud.com/document/Tencent-Video-Cloud-Toolkit-Privacy-Protection-Guidelines.html")!, title: model.title)
            vc.hidesBottomBarWhenPushed = true
            rootVC?.navigationController?.pushViewController(vc, animated: true)
//            if let url = URL(string: "https://privacy.qq.com/yszc-m.htm"), UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.openURL(url)
//            }
            
        case .agreement:
            let vc = TRTCWebViewController(url: URL(string: "https://web.sdk.qcloud.com/document/Tencent-Video-Cloud-Toolkit-User-Agreement.html")!, title: model.title)
            vc.hidesBottomBarWhenPushed = true
            rootVC?.navigationController?.pushViewController(vc, animated: true)
            
        case .disclaimer:
            let alert = UIAlertController(title: .disclaimerText, message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: .doneText, style: .default, handler: nil)
            alert.addAction(action)
            rootVC?.present(alert, animated: true, completion: nil)
            
        case .logout:
            logoutBtnClick()
        }
    }
}

class MineTableViewCellModel: NSObject {
    let title: String
    let image: UIImage?
    let type: MineListType
    init(title: String, image: UIImage?, type: MineListType) {
        self.title = title
        self.image = image
        self.type = type
        super.init()
    }
}

class MineTableViewCell: UITableViewCell {
    
    lazy var titleImageView: UIImageView = {
        let imageV = UIImageView(frame: .zero)
        return imageV
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = .white
        return label
    }()
    
    lazy var detailImageView: UIImageView = {
        let imageV = UIImageView(image: UIImage(named: "main_mine_detail"))
        return imageV
    }()
    
    var model: MineTableViewCellModel? {
        didSet {
            guard let model = model else {
                return
            }
            titleImageView.image = model.image
            titleLabel.text = model.title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(titleImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailImageView)
    }
    func activateConstraints() {
        titleImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView.snp_leading).offset(36)
            make.centerY.equalToSuperview()
        }
        detailImageView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleImageView)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleImageView)
            make.leading.equalTo(titleImageView.snp_centerX).offset(28)
            make.trailing.lessThanOrEqualTo(detailImageView.snp_leading).offset(-10)
        }
    }
    func bindInteraction() {
        
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = AppPortalLocalize("Demo.TRTC.Portal.Mine.personalcenter")
    static let disclaimerText = AppPortalLocalize("Demo.TRTC.Portal.disclaimerdesc")
    static let doneText = AppPortalLocalize("Demo.TRTC.Portal.confirm")
    static let logoutText = AppPortalLocalize("Demo.TRTC.Portal.Home.logout")
}
