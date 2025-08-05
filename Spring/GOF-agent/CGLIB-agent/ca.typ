CGLIB既可以代理接口，又可以代理类。底层采用继承的方式实现。所以被代理的目标类不能使用final修饰。

使用CGLIB，需要引入它的依赖：
#image("cglib.png")

#image("method.png")

MethodInterceptor接口中有一个方法intercept()，该方法有4个参数：

第一个参数：代理对象

第二个参数：目标方法

第三个参数：目标方法调用时的实参

第四个参数：代理方法

#image("strength.png")

#image("startnum.png")