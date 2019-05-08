import UIKit

var str = "Hello, playground"

class Item {
    var a = 0
}

var arrayA: [Item] = []
arrayA.append(Item())
arrayA[0].a = 1
arrayA

var arrayB: [Item] = arrayA
arrayB

arrayA[0].a = 2
arrayA
arrayB
