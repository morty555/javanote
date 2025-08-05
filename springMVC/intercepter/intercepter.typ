#image("scene.png")

#image("defination.png")

#image("creat.png")

#image("config.png")

#image("config2.png")

config2需要将拦截器纳入spring容器管理

#image("config3.png")

#image("configmore.png")

自上而下顺序

#image("result.png")

如果有3个拦截器，第三个返回false，那么123的prehandle都会输出，但是posthandle都不会输出，aftercompletion只有21执行