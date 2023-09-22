//
//  ViewController.swift
//  WebSocket
//
//  Created by Agnes Triselia Yudia on 22/09/23.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {

    private var webSocket: URLSessionWebSocketTask?

    private let closeButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = .white
    button.setTitle("Close", for: .normal)
    button.setTitleColor(.black, for: .normal)
    return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        let session = URLSession(configuration: .default, delegate: self,
        delegateQueue: OperationQueue())

        let url = URL(string: "wss://free.blr2.piesocket.com/v3/1?api_key=MXkNXcJAEtRWkk2dJfroAWQtS71guupl5oC8yb5Z&notify_self=1")
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()

        closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.center = view.center
    }

    //MARK: FUNCTIONS
    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping Error:", error)
            }
        })
    }
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo Ended".data(using: .utf8))
    }
    func send() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.send()
            self.webSocket?.send(.string("send new message: \(Int.random(in: 0...100))"), completionHandler: { error in
                if let error = error {
                    print("send error message:", error)
                }
            })
        }
    }
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got Data:", data)
                case .string(let message):
                    print("Got String:", message)
                @unknown default:
                    break
                }
            case.failure(let error):
                print("Receive error:", error)
            }
            self?.receive()
        })
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to Socket")
        ping()
        receive()
        send()
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close to Socket:", reason as Any)
    }

}


