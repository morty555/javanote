这种方式本质上是：通过工厂方法模式进行实例化。

第一步：定义一个Bean

public class Order {
}

第二步：定义具体工厂类，工厂类中定义实例方法

public class OrderFactory {

    public Order get(){

        return new Order();

    }
}

第三步：在Spring配置文件中指定factory-bean以及factory-method

#image("beanproperties.png")