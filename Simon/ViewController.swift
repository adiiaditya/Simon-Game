//
//  ViewController.swift
//  Simon
//
//  Created by Aditya on 27/06/16.
//  Copyright © 2016 Aditya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var sliderValueLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var gameStatusLabel: UILabel!
    @IBOutlet var gameRestartLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    
    var sequence = [Int]()
    var numOfLevels:Int = 1
    var currentLevel:Int = 1
    var guess = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sliderValueLabel.text = String(slider.value)
        gameStatusLabel.text = "Double tap to start!"
        gameRestartLabel.text = "Come let's play Simon"
    }
    
    func randomSequenceGenrator()
    {
        if currentLevel <= numOfLevels{
            for _ in 0..<currentLevel {
                sequence.append(Int(arc4random_uniform(4)))
            }
        }
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        numOfLevels = Int(slider.value)
        sliderValueLabel.text = String(numOfLevels)
    }

    func flashSequence() {
        let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        self.gameStatusLabel.text = "Watch carefully!"
        dispatch_async(queue) {
            for btnidx in self.sequence {
                dispatch_async(dispatch_get_main_queue()) {
                    //highlights the sequence
                    self.buttons[btnidx].highlighted = true
                }
                 //puts the thread to sleep
                NSThread.sleepForTimeInterval(1.0)
                dispatch_async(dispatch_get_main_queue()) {
                    self.buttons[btnidx].highlighted = false
                }
                NSThread.sleepForTimeInterval(1.0)
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.gameStatusLabel.text = "Tap out the sequence!"
            }
        }
    }

    @IBAction func buttonTapped(sender: UIButton) {//1 open
        if buttons[sequence[guess]] == sender {
            gameStatusLabel.text = "Good guess. Keep Going."
            guess += 1
            if guess == currentLevel
            {
                currentLevel = currentLevel + 1
                NSThread.sleepForTimeInterval(1.0)
                guess = 0
                sequence.removeAll()
                if (currentLevel > numOfLevels){
                    gameStatusLabel.text = "You win"
                    gameRestartLabel.text = "Double tap to Restart"
                    slider.enabled = true
                    sequence.removeAll()
                    currentLevel = 1
                    numOfLevels = Int(slider.value)
                }else{
                    self.startGame(self)
                }
            }
        }
        else {
            gameStatusLabel.text = "Wrong Guess!"
            guess = 0
            let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
            dispatch_async(queue) {
                // blink all buttons and restart game
                dispatch_async(dispatch_get_main_queue()) {
                    for btn in self.buttons {
                        btn.highlighted = true
                    }
                }
                NSThread.sleepForTimeInterval(1.0)
                dispatch_async(dispatch_get_main_queue()) {
                    for btn in self.buttons {
                        btn.highlighted = false
                    }
                }
                NSThread.sleepForTimeInterval(1.0)
                dispatch_async(dispatch_get_main_queue()) {
                    self.flashSequence()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Double tap on the center of the screen to start the game
    @IBAction func startGame(sender: AnyObject) {
        guess = 0
        self.gameRestartLabel.text = ""
        randomSequenceGenrator()
        slider.enabled = false
        flashSequence()
    }
}

