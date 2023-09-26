

open class Foo {
    
    public var name: String? 
    
    public init() {
        
    }
    
    public convenience init(name: String) {
        self.init()
        self.name = name
    }

    private func someFunction() {
        print("Hello world")
    }

}