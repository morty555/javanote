= flutter与dart学习
+ #link("https://medium.com/@younasud/understanding-immutable-and-mutable-objects-in-dart-for-flutter-development-77ca1faba90b")
  - 主要内容：理解可变对象和不可变对象
  - 文章将不可变对象举例为Java的String,如果改变string内的value就需要创建一个新的对象
  - 可变对象举例为list,可以通过add和remove等操作改变list中的value
  - 为什么需要不可变对象
    - 不可变对象的性质意味着其是线程安全的。由于不可变对象一旦创建就无法修改，因此可以在多个线程之间安全地共享，而无需担心发生意外更改。这在多线程或异步环境中尤为重要，因为在这些环境中，需要确保数据始终处于一致状态。
    - 相比之下，在这些情况下，可变对象更难处理。如果多个线程同时修改同一个可变对象，则存在数据竞争和其他同步问题的风险。这可能导致难以调试的错误和不可预测的行为。这里可以用多线程对int修改可能会丢失value的情况类比。如果是string只会创建两个对象，彼此不影响
    - 区分不可变对象和可变对象对 Flutter 开发至关重要的另一个原因是，它会影响代码效率。一般来说，不可变对象比可变对象更高效，因为它们可以安全地共享和重用，而无需创建新对象。这在对性能要求极高的代码中尤为重要，因为每一毫秒都至关重要。 
  - 在flutterapp中如何选择可变或是不可变对象
    - 答案是“视情况而定”。这个问题没有一成不变的答案，选择取决于多种因素，包括应用程序的具体需求、预期工作负载以及代码的整体设计。
    - 一般来说，尽可能使用不可变对象是一种很好的做法，尤其对于不太可能随时间改变的数据而言。这有助于简化代码并降低出错的风险。
    - 可变对象适用的场景
      - 如果需要维护一个频繁更新的大型数据集，那么像列表这样的可变对象可能比每次数据更改时都创建一个新的不可变对象更高效。


+ #link("https://stackoverflow.com/questions/50431055/what-is-the-difference-between-the-const-and-final-keywords-in-dart")
  - 其中的一个评论提到的一个链接
    #link("https://news.dartlang.org/2012/06/const-static-final-oh-my.html")
  - 主要内容：理解Dart中的const和final关键字  
    - “static”表示成员变量仅存在于类本身，而不是类的实例上。它的含义仅此而已，没有其他用途。static 会修改成员。
    - “final”表示单次赋值：final变量或字段必须有一个初始值设定项。一旦赋值，final变量的值就不能更改。final会修改变量
    - 在 Dart 中，“const” 的含义更加复杂和微妙。const 会修改值。你可以在创建集合时使用它，例如 `const [1, 2, 3]`，也可以在构造对象（而不是使用 `new`）时使用它，例如 `const Point(2, 3)`。在这里，`const` 表示对象的所有底层状态都可以在编译时完全确定，并且该对象将被冻结且完全不可变。。
    - const 对象有一些有趣的特性和限制：
      - 它们必须由编译时可计算的数据创建。const 对象无法访问任何需要在运行时计算的内容。例如，1 + 2 是一个有效的 const 表达式，但 `new DateTime.now()` 则不是。
      - 它们是深度传递不可变的。如果一个 final 字段包含一个集合，那么该集合本身仍然可以是可变的。如果一个集合是 const 的，那么其中的所有内容也必须是 const 的，并且递归地如此。
      - 它们是规范化的。这有点像字符串驻留（即字符串常量池）：对于任何给定的 const 值，无论 const 表达式被求值多少次，都会创建一个 const 对象并重复使用。
    - 我认为 Dart 在保持语义和关键字清晰明确方面做得相当不错。（以前 `const` 既可以表示 `const`，也可以表示 `final`，这很容易让人困惑。）唯一的缺点是，当你想要指定一个类本身的成员变量，并且该成员变量只能赋值一次时，你必须同时使用 `static` 和 `final` 这两个关键字：`static` 和 `final`。

+ #link("https://blog.flutter.dev/announcing-dart-null-safety-beta-4491da22077a")
  - 主要内容：Dart 和 Flutter 的空值安全
    - 空安全是“选择加入”的
      - 迁移前：String 变量可以被赋值 null
      - 迁移后：编译期直接报错，禁止将 null 赋值给不可空类型
    - 空安全迁移 

+ #link("https://dart.dev/libraries/async/async-await")
  - 主要内容：介绍dart的异步
    - 为什么异步代码很重要
      - 异步操作允许程序在等待另一项操作完成的同时完成其他工作。
      - 这类异步计算通常以数组形式返回结果Future ，如果结果包含多个部分，则以数组形式返回结果Stream
    - 什么是future？  
      - Future 表示异步操作的结果，可以有两种状态：uncompleted or completed.
    - uncompleted
      - 调用异步函数时，它会返回一个未完成的 Future 对象。该 Future 对象会等待函数的异步操作完成或抛出错误。
    - completed
      - 如果异步操作成功，则 Future 对象会返回一个值并完成；否则，它会返回一个错误并完成。
    - completed with a value
      - 类型为 `T` 的 FutureFuture/<T>会返回一个类型为 `T` 的值T。例如，类型为 `T` 的 FutureFuture/<String>会生成一个字符串值。如果 Future 没有生成可用值，则该 Future 的类型为 `None` Future/<void>。
    - Completing with an error
      - 如果异步操作失败，返回error
    - 当你调用一个返回 future 的函数时，该函数会将待完成的工作排队，并返回一个未完成的 future。当一个 future 对象的操作完成时，该 future 对象会返回一个值或一个错误。
    - async和await
      - 要定义异步函数，添加async在函数体之前：
      - await只在async函数中使用
    - 异步和同步函数的区别
      - 返回类型从string变为Future/<String>，也就是基本类型变为future  
      - 函数声明要加async,调用函数要加await
    - 使用 async 和 await 的执行流程
      - 函数async在遇到第一个await关键字之前都是同步执行的。这意味着在async函数体内部，第一个await关键字之前的所有同步代码都会立即执行。
    - trycatch处理错误

+ #link("https://flutter.dev/docs/development/ui/layout/constraints")
  - 主要内容：Flutter 的组件约束、大小、定位及其交互方式模型。
    - flutter布局和html不同
    - Constraints go down. Sizes go up. Parent sets position的解释为
      - 小部件会从其父部件 获取自身的约束。约束条件由四个双精度浮点数组成：最小宽度、最大宽度、最小高度和最大高度。   
      - 然后，该组件会遍历自身的子组件列表。组件会逐一告知子组件它们的 约束条件（每个子组件的约束条件可能不同），然后询问每个子组件想要调整到什么大小。
      - 然后，该组件会逐个 定位其子组件 （沿x轴水平定位，沿y轴垂直定位）​​
      - 最后，该组件会告诉其父组件自身的大小
    - Limitations
      - Flutter 的布局引擎设计为单遍渲染。这意味着 Flutter 可以非常高效地布局其组件，但也带来了一些局限性：
        - 小部件只能在其父级控件设定的约束范围内决定自身大小。这意味着小部件通常 不能随意调整大小。
        - 小部件无法知道也无法决定自己在屏幕上的位置，因为小部件的位置是由其父级决定的。
        - 由于父级的大小和位置反过来又取决于它自己的父级，因此如果不考虑整个树，就不可能精确定义任何小部件的大小和位置。
        - 如果子元素需要的尺寸与父元素不同，而父元素没有足够的信息来对齐，那么子元素的尺寸请求可能会被忽略。 定义对齐方式时务必具体明确。
    - 在 Flutter 中，组件由其底层对象渲染 RenderBox 。Flutter 中的许多组件，尤其是那些只接受一个子组件的组件，会将它们的约束传递给子组件。
    - 一般来说，根据盒子处理约束的方式，盒子可以分为三种类型：
      - 那些力求做到尽可能大的盒子。例如，Center 和ListView 使用的盒子。
      - 那些试图与孩子体型相同的盒子。例如，Transform 和 Opacity使用的盒子。
      - 那些力求达到特定尺寸的盒子。例如：Image和Text使用的盒子。  
    - 一些组件例如CONTAINER会由于他们的构造函数在不同type之间变化，Container的构造函数是想要变得尽可能大的，但如果你给它指定一个宽度，它会尽量遵循这个宽度值，并保持该特定大小。
    - 其他元素，例如行和列（弹性盒子），会根据所施加的约束而变化，如弹性部分所述。
    #image("/assets/Screenshot_20251226_103911.png")
    #image("/assets/Screenshot_20251226_103938.png")
    #image("/assets/Screenshot_20251226_104223.png")
    #image("/assets/Screenshot_20251226_104921.png")  
    #image("/assets/Screenshot_20251226_105005.png")
    #image("/assets/Screenshot_20251226_105240.png")
    - Container 尝试顺序是
      - 如果有 alignment → 尝试使用它
      - 否则尝试根据 child 决定大小
      - 再看 width / height / constraints
      - 再尝试撑满父组件
      - 最后才退化为最小尺寸
    #image("/assets/Screenshot_20251226_110120.png")
    - 红色 Container 决定
      - 里面四周要空出 20 像素，不允许 child 占用
    - 红色 Container 给绿色 child 的约束
      - 最大可用空间 = 自己的空间 - padding
    - 绿色 Container 并不知道 padding 的存在
    #image("/assets/Screenshot_20251226_112317.png")
    - ConstrainedBox 永远不能打破父组件的约束
    - tight constraints（如屏幕、Expanded、SizedBox）是不可反抗的
    - 只有在 loose constraints 下，ConstrainedBox 才能真正限制大小。如果在图示代码外层加入center约束既可，因为center是loose
    - #image("/assets/Screenshot_20251226_112440.png")
    - loose和tight组件区分
      #image("/assets/Screenshot_20251226_112544.png")
      #image("/assets/Screenshot_20251226_112600.png")
      #image("/assets/Screenshot_20251226_112617.png")
      - loose和tight区别
        - 严格约束只提供一种可能性，即一个精确的尺寸。换句话说，严格约束的最大宽度等于其最小宽度，最大高度等于其最小高度。
        - 例如，App 小部件包含在 RenderView 类中：应用程序的构建函数返回的子元素使用的框被赋予了一个约束，强制其完全填充应用程序的内容区域（通常是整个屏幕）。
        - 另一个例子：如果你在应用程序渲染树的根部将一堆盒子相互嵌套，由于盒子的紧密约束，它们都会正好彼此契合。
        #image("/assets/Screenshot_20251226_115905.png")
        - 宽松约束是指最小值为零、最大值非零的约束。
        - 有些盒子会放宽传入的限制，这意味着最大值保持不变，但最小值被移除，因此小部件的最小宽度和高度都可以为零。
        - Center 的目的是将其从父级（屏幕）接收到的严格约束转换为对其子级（容器）的宽松约束。
    #image("/assets/Screenshot_20251226_112641.png")
    #image("/assets/Screenshot_20251226_112754.png")
    #image("/assets/Screenshot_20251226_112827.png")
    #image("/assets/Screenshot_20251226_112926.png")
    #image("/assets/Screenshot_20251226_112942.png")
    #image("/assets/Screenshot_20251226_113009.png")
    #image("/assets/Screenshot_20251226_113158.png")
    - LimitedBox 只有在“收到无限约束时”，才会使用 maxWidth / maxHeight
    - UnconstrainedBox给的限制是

        BoxConstraints(
          minWidth: 0,
          maxWidth: ∞,
        )
    - 而center给的限制是
    BoxConstraints(
      minWidth: 0,
      maxWidth: 屏幕宽度，
    )
    - center是有限的宽松，而UnconstrainedBox是无限的宽松。
    #image("/assets/Screenshot_20251226_113441.png")
    #image("/assets/Screenshot_20251226_113623.png")
    - text本身自带宽度，它在没有被强制约束时，会按内容自然排版并占用对应宽度。
    - 当使用const FittedBox(child: Text('Some Example Text.'))，fittedbox的父约束会强制子组件填满父组件，而fittedbox的父组件是tight的屏幕，因此text会被强制撑满屏幕宽度，然后fittedbox会按比例缩放text以适应屏幕宽度。
    - 当使用const Center(child: FittedBox(child: Text('Some Example Text.')))，center会给fittedbox一个loose的屏幕宽度约束，因此fittedbox会按text的自然宽度来布局，然后fittedbox会按比例缩放text以适应自然宽度。
    #image("/assets/Screenshot_20251226_114244.png")
    #image("/assets/Screenshot_20251226_114300.png")
    #image("/assets/Screenshot_20251226_114320.png")
    #image("/assets/Screenshot_20251226_114355.png")
    - Row不会对其子元素施加任何限制，而是允许它们拥有任意大小。row会将其子元素放在一行中，并根据子元素的大小来确定自身的宽度，任何多余的空间都会保持为空。
    #image("/assets/Screenshot_20251226_114456.png")
    - 由于Row不会对其子元素施加任何限制，因此子元素很可能过大，超出元素的可用宽度Row。在这种情况下，就像 `<div>` 元素一样 UnconstrainedBox，`<div>` 元素Row会显示“溢出警告”。
    #image("/assets/Screenshot_20251226_114533.png")
    - 当一个Row元素的子元素被包裹在一个Expanded组件中时，该组件将Row不再允许该子元素定义自己的宽度。
    - 相反，它会根据其他子元素来定义 Expanded 的宽度，然后 Expanded 小部件才会强制原始子元素拥有 Expanded 的宽度。
    - 如果 Row 的所有子元素都包裹在 Expanded 小部件中，则每个 Expanded 小部件的大小与其 flex 参数成正比，并且只有在这种情况下，每个 Expanded 小部件才会强制其子元素具有 Expanded 的宽度。
    - 换句话说，Expanded 会忽略其子元素的首选宽度。 一旦子组件被 Expanded 包裹，它自己“想要多宽”就不重要了，最终宽度由父布局（如 Row / Column）统一分配。
      - 什么叫「子元素的首选宽度」
        - 子组件在不受强制约束时根据自身内容或 width 属性希望占用的大小
    - flex 只在以下三个条件同时满足时才起作用：
      - 父组件是 Row 或 Column
      - 子组件是 Flexible 或 Expanded
      - 主轴方向上存在 剩余空间
    #image("/assets/Screenshot_20251226_115131.png")
    - 使用“flexible”而非“expanded”的唯一区别在于，“flexible”允许其子元素拥有与自身相同或更小的宽度，而“expanded”则强制其子元素拥有与自身完全相同的宽度。但“expanded”和“flexible”在调整自身尺寸时都会忽略其子元素的宽度。
    - 这意味着无法按比例扩展 Row 的子元素。Row 要么使用子元素的精确宽度，要么在使用 Expanded 或 Flexible 属性时完全忽略子元素的宽度。
    #image("/assets/Screenshot_20251226_115521.png")
    - 当一个组件告诉它的子组件它可以小于某个特定尺寸时，我们称该组件为其子组件提供了宽松约束。
    #image("/assets/Screenshot_20251226_115630.png")
    - Unbounded constraints
      - 在某些情况下，盒子的约束是无界的，或者说是无限的。这意味着最大宽度或最大高度被设置为double.infinity。
      - 试图尽可能大的盒子在给定无界约束时无法正常工作，并且在调试模式下会抛出异常。
      - 渲染框出现无界约束的最常见情况是位于弹性框（行或列）内，以及位于可滚动区域（例如 ListView 和其他 ScrollView 子类）内。
        - 无界约束（unbounded constraint）」的本质就是：父组件在某个方向上不知道该给子组件多大空间
      - 例如，ListView 会尝试扩展以适应其横向方向上的可用空间（例如，它可能是一个垂直滚动块，并试图与其父级元素一样宽）。如果将一个垂直滚动的 ListView 嵌套在一个水平滚动的 ListView 中，则内部列表会尝试尽可能宽，而由于外部列表可以沿该方向滚动，因此内部列表的宽度将无限大。
    - flex 
      - 弹性盒子（Row和 Column）的行为取决于其约束在其主要方向上是有界的还是无界的。
      - 主方向上有边界约束的弹性盒子会尽可能地增大尺寸。
      - 主方向上设置了无界约束的弹性盒子会尝试将其子元素适应该空间。每个子元素的flex值都必须设置为零，这意味着当弹性盒子位于另一个弹性盒子或可滚动元素内部时，不能使用 Expanded 此方法；否则会抛出异常。
      - 交叉方向（宽度Column 或高度Row）绝不能无限制，否则就无法合理地对齐其子元素。

+ #link("https://dart.dev/guides/language/language-tour#exceptions")
  - try-on-catch 和 throw

+ #link("https://dart.dev/guides/libraries/futures-error-handling ")
  - 有关编写异步代码时处理错误和异常
  - 注册的回调函数会根据以下规则触发：如果 Future 执行完毕并返回一个值，则 then() 的回调函数会触发；如果 Future 执行完毕并返回一个错误，则 catchError() 的回调函数会触发。
  - 在处理 Futures 时，链式调用 then() 和 catchError() 是一种常见的模式，可以将其视为 try-catch 块的粗略等价物。
  - 无论错误是源自 myFunc() 还是 then()，catchError() 都能成功处理它。
  - 如果需要区分then里面发生的错误和then之前发生的错误，可以使用以下方法：
    - 在 then() 中返回一个新的 Future，并在该 Future 上注册 catchError() 回调函数。
    - 使用 onError 参数为 then() 注册一个错误处理程序。onerror处理后若没有其他错误则不会走到catcherror处理。
  - 举例如下：
    #image("/assets/Screenshot_20251228_110820.png")
    - 在上面的示例中，asyncErrorFunction() 的 Future 的错误由 onError 回调处理；anotherAsyncErrorFunction() 导致 then() 的 Future 以错误完成；此错误由 catchError() 处理。
  - 一般来说，不建议实现两种不同的错误处理策略：只有在有充分理由需要在 then() 中捕获错误时才注册第二个回调函数。
  - #image("/assets/Screenshot_20251228_111212.png")
    - 在上面的代码中，`one()` 返回的 Future 对象会返回一个值，而 `two()` 返回的 Future 对象会返回一个错误。当对一个返回错误的 Future 对象调用 `then()` 方法时，`then()` 的回调函数不会触发。相反，`then()` 返回的 Future 对象会返回其接收者的错误。在我们的示例中，这意味着在调用 `two()` 之后，后续所有 `then()` 返回的 Future 对象都会返回 `two()` 返回的错误。该错误最终会在 `catchError()` 方法中被处理。
  - catchError() 接受一个可选的命名参数 test，允许我们查询抛出的错误类型。
    #image("/assets/Screenshot_20251228_111821.png")
    - 发生错误后，会判断每一个catchError中test中展示的类型是否匹配，如果匹配则执行对应的回调函数。
  - 使用 whenComplete() 的异步 try-catch-finally 语句
    - 如果说 then().catchError() 类似于 try-catch，那么 whenComplete() 就相当于 'finally'。whenComplete() 中注册的回调函数会在 whenComplete() 的接收者完成时被调用，无论接收者返回的是值还是错误
    - 也就是whenComplete()前的函数的返回值
  - whenComplete() 函数内部出现的错误
    - 如果 whenComplete() 的回调函数抛出错误，则 whenComplete() 的 Future 对象将以该错误为返回值完成。
  - 必须在 Future 完成之前安装错误处理程序：这可以避免 Future 完成时出现错误，但错误处理程序尚未附加，导致错误意外传播的情况。
  - 返回 Future 的函数几乎总是应该在 Future 中抛出错误。由于我们不希望此类函数的调用者需要实现多种错误处理方案，因此我们需要防止任何同步错误泄露。
    #image("/assets/Screenshot_20251228_113849.png")
    - 因为OBTAIN函数不在FUTURE链里，无法被CATCHERROR捕获，因此若这个报错就直接退出了，就会产生问题
    - 为确保函数不会意外抛出同步错误，一种常见的做法是将函数体包装在一个新的 Future.sync() 回调函数中
    - 如果回调函数返回一个非 Future 类型的值，则 `Future.sync()` 的 Future 将使用该值完成。如果回调函数抛出异常（如上例所示），则 Future 将以错误信息完成。如果回调函数本身返回一个 Future 类型，则该 Future 的值或错误信息将作为 `Future.sync()` 的 Future 完成。
    - `Future.sync()` 可以让你的代码免受未捕获异常的影响。如果你的函数中包含大量代码

+ #link("https://dart.dev/guides/libraries/library-tour#stream")
  - 如何使用 Dart 核心库的主要功能


+ #link(" https://dart.dev/tutorials/language/streams")
  - Dart中的异步编程以Future和Stream类为特征。
  - Future 代表一个不会立即完成的计算。普通函数会返回结果，而异步函数则返回一个 Future，该 Future 最终会包含结果。Future 会在结果准备就绪时通知您。
  - 流是一系列异步事件。它类似于异步可迭代对象——只不过，流不是在你请求时才获取下一个事件，而是在事件准备就绪时通知你。
  - 创建流的方法有很多种，这又是另一个话题了，但它们的用法都一样：异步 for 循环（通常简称为 await for）会像 for 循环遍历 Iterable 对象一样遍历流中的事件。
  - 在 Dart 中，yield 的作用是 在异步生成器函数中产生一个值，并将其发送到返回的 Stream。它和普通函数的 return 不同，return 是一次性返回整个函数的结果，而 yield 是 逐个产生值，允许函数 在多次调用之间保持状态。
  - async\* 是 异步生成器函数 的标记,搭配YIELD使用
  - 当流中不再有事件时，流就会结束，接收事件的代码会收到此通知，就像它收到新事件到达的通知一样。当使用 await for 循环读取事件时，循环会在流结束时停止。
  - 在某些情况下，流完成之前会发生错误；可能是从远程服务器获取文件时网络出现故障，或者创建事件的代码存在错误，但需要有人知道这一点。
  - 流也可以像传递数据事件一样传递错误事件。大多数流会在遇到第一个错误后停止，但也存在会传递多个错误，以及在错误事件发生后传递更多数据的流。本文档仅讨论最多传递一个错误的流。
  - 使用 await for 读取流时，错误是由循环语句抛出的，这也会导致循环结束。你可以使用 try-catch 语句捕获该错误。
  - Stream 类包含许多辅助方法，可以像 Iterable 类中的方法一样，对流执行常见操作。例如，您可以使用 Stream API 中的 lastWhere() 方法查找流中的最后一个正整数。
  - 最常见的数据流包含一系列事件，这些事件构成一个更大的整体。事件需要按正确的顺序传递，并且不能遗漏任何一个。读取文件或接收 Web 请求时，您得到的就是这种数据流。
  - 这样的数据流只能监听一次。如果之后再次监听，可能会错过初始事件，导致后续数据流失去意义。开始监听时，数据会分块获取并提供。
  - 另一种类型的流用于处理单个消息，这些消息可以一次处理一条。例如，这种类型的流可以用于浏览器中的鼠标事件。
  - 您可以随时开始收听此类流，并获取收听过程中触发的事件。多个监听器可以同时收听，取消之前的订阅后，您可以稍后再次收听。
  - `transform()` 函数并非仅用于错误处理；它是一个更通用的流式“映射”。普通的映射需要为每个传入事件分配一个值。然而，尤其对于 I/O 流而言，可能需要多个传入事件才能产生一个输出事件。`StreamTransformer` 可以处理这种情况。例如，像 Utf8Decoder 这样的解码器就是转换器。转换器只需要一个 `bind()` 函数，该函数可以轻松地用异步函数实现。
  - 要创建新的 Stream 类型，只需扩展 Stream 类并实现 listen() 方法——Stream 上的所有其他方法都会调用 listen() 才能正常工作。
  - `listen()` 方法允许你开始监听一个流。在你监听之前，该流是一个静态对象，仅描述你想要监听的事件。监听之后，会返回一个 `StreamSubscription` 对象，该对象代表正在产生事件的活动流。这类似于 `Iterable` 对象本身就是一个对象集合，但实际执行迭代操作的是迭代器。
  - 流订阅功能允许您暂停订阅、暂停后恢复订阅以及完全取消订阅。您可以设置回调函数，以便在每次数据事件或错误事件发生时以及流关闭时调用。


+ #link("https://docs.flutter.dev/data-and-backend/state-mgmt/simple")
  - 状态存储与管理
  - 在 Flutter 中，将状态放在使用它的组件之上是合理的。
  - 在像 Flutter 这样的声明式框架中，如果你想更改 UI，就必须重新构建它。没有简单的方法可以调用 `MyCart.updateWith(somethingNew)`。换句话说，很难通过调用方法来从外部命令式地更改组件。即使你能做到这一点，你也是在与框架对抗，而不是让它帮助你。
  - 即使你使用以上的修改组件的方式可以成功运行，你需要考虑当前用户界面的状态，并将新数据应用到其中。这样很难避免出现错误。
  - 在 Flutter 中，每次组件内容发生变化时，都需要创建一个新的组件。例如，不要使用 `MyCart.updateWith(somethingNew)`（方法调用），而要使用 `MyCart(contents)`（构造函数）。由于只能在父组件的 `build` 方法中创建新组件，因此如果要更改组件内容，则该组件必须位于 `MyCart` 的父组件或更高级别的组件中。
  - 在我们的示例中，内容需要存储在 MyApp 中。每当内容发生更改时，MyApp 都会从上层重新构建 MyCart（稍后会详细介绍）。因此，MyCart 无需关心生命周期——它只需声明针对给定内容要显示的内容即可。当内容发生变化时，旧的 MyCart 组件会消失，并完全被新的组件替换。
  #image("/assets/Screenshot_20260109_100635.png")
  - 这就是我们所说的控件是不可变的。它们不会改变——它们会被替换。
  - Flutter 提供了一些机制，允许组件向其子组件（换句话说，不仅是它们的子组件，还包括它们之下的所有组件）提供数据和服务。
  - 相反，我们将使用一个可以与底层组件配合使用但又简单易用的软件包。它叫做 provider。
  - ChangeNotifier
    - ChangeNotifier 是 Fl​​utter SDK 中包含的一个简单的类，它为监听器提供变更通知。换句话说，如果某个对象是 ChangeNotifier，你就可以订阅它的变更。
    - 在提供程序中，ChangeNotifier 是封装应用程序状态的一种方法。对于非常简单的应用程序，一个 ChangeNotifier 就足够了。在复杂的应用程序中，您将拥有多个模型，因此也需要多个 ChangeNotifier。
    ```flutter
      class CartModel extends ChangeNotifier {
    /// Internal, private state of the cart.
    final List<Item> _items = [];

    /// An unmodifiable view of the items in the cart.
    UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

    /// The current total price of all items (assuming all items cost $42).
    int get totalPrice => _items.length * 42;

    /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
    /// cart from the outside.
    void add(Item item) {
      _items.add(item);
      // This call tells the widgets that are listening to this model to rebuild.
      notifyListeners();
    }

    /// Removes all items from the cart.
    void removeAll() {
      _items.clear();
      // This call tells the widgets that are listening to this model to rebuild.
      notifyListeners();
    }
  }

    ```
    - 唯一与 ChangeNotifier 相关的代码是调用 notifyListeners() 方法。每当模型发生可能影响应用 UI 的变化时，都应该调用此方法。CartModel 中的其他所有内容都是模型本身及其业务逻辑。
    - 测试代码如下：
    ```flutter
          test('adding item increases total cost', () {
        final cart = CartModel();
        final startingPrice = cart.totalPrice;
        var i = 0;
        cart.addListener(() {
          expect(cart.totalPrice, greaterThan(startingPrice));
          i++;
        });
        cart.add(Item('Dash'));
        expect(i, 1);
      });
 
    ```
    - ChangeNotifierProvider 是一个组件，它向其子组件提供 ChangeNotifier 的实例。它来自 provider 包。
  - ChangeNotifierProvider
    - ChangeNotifierProvider 是一个组件，它向其子组件提供 ChangeNotifier 的实例。
    - 我们已经知道应该把 ChangeNotifierProvider: 放在需要访问它的组件上方的哪个位置。对于 CartModel 来说，这意味着要放在 MyCart 和 MyCatalog 的上方。
    - ChangeNotifierProvider 非常智能，除非绝对必要，否则不会重新构建 CartModel。此外，当不再需要 CartModel 实例时，它还会自动调用 dispose() 方法。
    - 如果要提供多个类，可以使用 MultiProvider
    - ChangeNotifierProvider 是一个“带生命周期管理的状态工厂 + 依赖注入容器 + 观察者调度器”
  - Consumer
    - 我们必须指定要访问的模型类型。在本例中，我们需要的是 CartModel，所以我们写成 Consumer<CartModel>。如果不指定泛型（<CartModel>），provider 包将无法提供帮助。provider 基于类型，如果没有类型，它就不知道你想要什么。
    - Consumer 组件唯一必需的参数是 builder 函数。Builder 函数会在 ChangeNotifier 发生变化时被调用。（换句话说，当你在模型中调用 notifyListeners() 时，所有对应 Consumer 组件的 builder 方法都会被调用。）
    - 构建器会接收三个参数。第一个参数是上下文，每个构建方法中都会提供该参数。
    - 构建器函数的第二个参数是 ChangeNotifier 的实例。这正是我们最初需要的。您可以使用模型中的数据来定义 UI 在任何给定时刻的外观。
    - 第三个参数是 child，它的作用是优化。如果你的 Consumer 下有一个庞大的 widget 子树，并且该子树不会随着模型的变化而变化，那么你可以只构建一次，然后通过构建器获取它。
    ```flutter
        return Consumer<CartModel>(
      builder: (context, cart, child) => Stack(
        children: [
          // Use SomeExpensiveWidget here, without rebuilding every time.
          ?child,
          Text('Total price: ${cart.totalPrice}'),
        ],
      ),
      // Build the expensive widget here.
      child: const SomeExpensiveWidget(),
    );

    ```
    - 如这段代码，children不会因为 notifyListeners() 重新 build，? 表示 child 可能为空（Flutter 空安全）
    - 每次 CartModel 改变 → builder 重建 → 这个 Text 更新
    - 最佳实践是将 Consumer 组件尽可能放置在组件树的深层位置。您肯定不希望仅仅因为某个细节发生了变化就重建大部分 UI。也就是让builder放置尽可能深层嵌套中
    ```flutter
        // DO THIS
    return HumongousWidget(
      // ...
      child: AnotherMonstrousWidget(
        // ...
        child: Consumer<CartModel>(
          builder: (context, cart, child) {
            return Text('Total price: ${cart.totalPrice}');
          },
        ),
      ),
    );
 
    ```
  - provider.of
    - 有时候，你并不需要模型中的数据来改变用户界面，但仍然需要访问这些数据。例如，一个“清空购物车”按钮需要允许用户从购物车中移除所有商品。它不需要显示购物车的内容，只需要调用 `clear()` 方法即可。
    - 我们可以使用 Consumer<CartModel>，但这会造成浪费。我们会要求框架重新构建一个不需要重新构建的组件。
    - 对于此用例，我们可以使用 Provider.of，并将 listen 参数设置为 false。
    ```flutter
    Provider.of<CartModel>(context, listen: false).removeAll();
 
    ```
    - 在 build 方法中使用上述代码行不会导致在调用 notifyListeners 时重新构建此小部件。

+ #link("https://www.freecodecamp.org/news/provider-pattern-in-flutter/")
  - 提供者模式
    - 调用 notifyListeners() 函数。这将触发应用程序中所有监听该事件的组件发生改变。
    - 这就是 Flutter 中提供者模式的妙处——你无需关心手动分发​​到流。
  - 主要内容讲述的是将flutter初始化项目的示例修改成提供者模式
  - 也就是说，原来是页面管理变量状态，现在将状态变量移交到另外一个类，页面通过这个类获取而不修改，修改状态由提供者类自己管理，是否刷新 UI 完全由 Provider 决定 ，而原来修改状态要手动set。同时因为现在只有依赖 Counter 的 Widget 会重建，细粒度刷新让资源更有效利用

+ #link("https://bloclibrary.dev/why-bloc/")
  - bloc
    - Bloc 可以轻松地将表现层与业务逻辑分离，从而使您的代码运行速度更快、易于测试且可重用。
    - 使用 await for 是因为 Stream 中的数据是异步产生的。await for 会等待流中的每个事件，并在流结束后再继续执行，从而保证在返回结果之前已经处理完所有数据。
  - cubit
    - Cubit 是一个继承自 BlocBase 的类，可以对其进行扩展以管理任何类型的状态。
    - Cubit 可以公开一些函数，这些函数可以被调用来触发状态变化。
    - 状态是 Cubit 的输出，代表应用程序状态的一部分。UI 组件可以接收到状态通知，并根据当前状态重新绘制自身的部分内容。
    ```
        class CounterCubit extends Cubit<int> {
      CounterCubit() : super(0);
    }
    ```
    - 创建 Cubit 时，我们需要定义 Cubit 将要管理的状态类型。以上面的 CounterCubit 为例，状态可以用 int 类型表示，但在更复杂的情况下，可能需要使用类而不是基本类型。
    - 创建 Cubit 的第二步是指定初始状态。我们可以通过调用 super 并传入初始状态值来实现。在上面的代码片段中，我们将初始状态内部设置为 0，但我们也可以通过接受外部值来使 Cubit 更加灵活：
    ```
        class CounterCubit extends Cubit<int> {
      CounterCubit(int initialState) : super(initialState);
    }
    ```
    - 这将允许我们实例化具有不同初始状态的 CounterCubit 实例
    ```
        class CounterCubit extends Cubit<int> {
      CounterCubit() : super(0);

      void increment() => emit(state + 1);

    }```
    - 在上面的代码片段中，CounterCubit 公开了一个名为 increment 的公共方法，可以从外部调用该方法来通知 CounterCubit 递增其状态。调用 increment 方法后，我们可以通过状态获取器访问 Cubit 的当前状态，并通过将当前状态加 1 来发出新的状态。
    - 使用cubit
    ```
        void main() {
      final cubit = CounterCubit();
      print(cubit.state); // 0
      cubit.increment();
      print(cubit.state); // 1
      cubit.close();
    }
    ```
    - cubit stream
    ```
    Future<void> main() async {
  final cubit = CounterCubit();
  final subscription = cubit.stream.listen(print); // 1
  cubit.increment();
  await Future.delayed(Duration.zero);
  await subscription.cancel();
  await cubit.close();
}
    ```
    - 在上面的代码片段中，我们订阅了 CounterCubit，并在每次状态改变时调用 print 函数。然后，我们调用 increment 函数来生成一个新的状态。最后，当我们不再需要接收更新时，我们调用 cancel 函数来取消订阅并关闭 Cubit。
    - 只有在调用 cubit.increment() 之后，才会输出 1
    - 当 Cubit 发出新状态时，就会发生一次 Change 事件。我们可以通过重写 onChange 方法来观察给定 Cubit 的所有状态变化。
    ```
            class CounterCubit extends Cubit<int> {
          CounterCubit() : super(0);

          void increment() => emit(state + 1);

          @override
          void onChange(Change<int> change) {
            super.onChange(change);
            print(change);
          }
        }
        ```
        ```
        void main() {
      CounterCubit()
        ..increment()
        ..close();
    }
    ```
    - 使用 Bloc 库的一个额外好处是，我们可以集中访问所有变更。虽然在这个应用中我们只有一个 Cubit，但在大型应用中，通常会有多个 Cubit 来管理应用状态的不同部分。如果我们想要响应所有变更，只需创建我们自己的 BlocObserver 即可。
    ```
        class SimpleBlocObserver extends BlocObserver {
      @override
      void onChange(BlocBase bloc, Change change) {
        super.onChange(bloc, change);
        print('${bloc.runtimeType} $change');
      }
    }
    ```
    - 要使用 SimpleBlocObserver，我们只需要调整主函数：
    ```
        void main() {
      Bloc.observer = SimpleBlocObserver();
      CounterCubit()
        ..increment()
        ..close();
    }
    ```
    - Cubit Error Handling
    ```
        class CounterCubit extends Cubit<int> {
      CounterCubit() : super(0);

      void increment() {
        addError(Exception('increment error!'), StackTrace.current);
        emit(state + 1);
      }

      @override
      void onChange(Change<int> change) {
        super.onChange(change);
        print(change);
      }

      @override
      void onError(Object error, StackTrace stackTrace) {
        print('$error, $stackTrace');
        super.onError(error, stackTrace);
      }
    }
    ```
    - BlocObserver 中也可以重写 onError 方法来全局处理所有报告的错误
    ```
        class SimpleBlocObserver extends BlocObserver {
      @override
      void onChange(BlocBase bloc, Change change) {
        super.onChange(bloc, change);
        print('${bloc.runtimeType} $change');
      }

      @override
      void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
        print('${bloc.runtimeType} $error $stackTrace');
        super.onError(bloc, error, stackTrace);
      }
    }
    ```
  - Bloc
    - Bloc 是一个更高级的类，它依赖事件而非函数来触发状态变化。Bloc 也继承自 BlocBase，这意味着它拥有与 Cubit 类似的公共 API。然而，Bloc 并非调用函数并直接发出新状态，而是接收事件并将传入的事件转换为传出的状态。
    - sealed class CounterEvent {} 这里的sealed限制CounterEvent 只能在「同一个库（library）」中被继承，其他文件 / 包里 不能再随意继承它，sealed可以保证switch时的安全性
    - Bloc 要求我们通过 on<Event> API 注册事件处理程序，而不是像 Cubit 那样使用函数。事件处理程序负责将所有传入事件转换为零个或多个传出状态。
    - bloc的使用和cubit几乎一模一样，因此此处不赘述代码实现
    - bloc的observe和cubit也几乎一样，不同的是，由于 Bloc 是事件驱动的，我们还能捕获触发状态改变的信息。我们可以通过重写 `onTransition` 来实现这一点。从一个状态到另一个状态的改变称为转换 (Transition)。转换由当前状态、事件和下一个状态组成。
    - Bloc 实例的另一个独特之处在于，它允许我们重写 onEvent 方法，该方法会在向 Bloc 添加新事件时被调用。与 onChange 和 onTransition 一样，onEvent 既可以局部重写，也可以全局重写。
    - 与 Cubit 类似，每个 Bloc 都有 addError 和 onError 方法。我们可以通过在 Bloc 内部的任何位置调用 addError 来表明发生了错误。然后，我们可以像在 Cubit 中一样，通过重写 onError 来处理所有错误。
  - BLOC vs cubit
    - 使用 Cubit 的最大优势之一在于其简洁性。创建 Cubit 时，我们只需定义状态以及用于更改状态的函数。相比之下，创建 Bloc 时，我们需要定义状态、事件以及 EventHandler 的实现。这使得 Cubit 更易于理解，并且代码量更少。
    - Cubit 的实现更加简洁，它不再单独定义事件，而是让函数本身充当事件。此外，使用 Cubit 时，我们可以从任何位置调用 emit 函数来触发状态更改。
    - 使用 Bloc 的最大优势之一在于能够了解状态变更的顺序以及触发这些变更的确切原因。对于对应用程序功能至关重要的状态，采用事件驱动的方法可能非常有益，因为它可以捕获所有事件以及状态变更。
    - 应用程序状态从已认证变为未认证可能有很多原因。例如，用户可能点击了注销按钮并请求退出应用程序。另一方面，用户的访问令牌可能被撤销，导致其被强制注销。使用 Bloc，我们可以清晰地追踪应用程序状态的演变过程。
    - Bloc 比 Cubit 更胜一筹的另一个方面是，当我们想要利用诸如 buffer、debounceTime、throttle 等响应式运算符时。
  - BlocBuilder 
    - 是一个 Flutter 组件，它需要一个 Bloc 对象和一个构建函数。BlocBuilder 负责根据新的状态构建组件。BlocBuilder 与 StreamBuilder 非常相似，但它的 API 更简洁，从而减少了所需的样板代码量。构建函数可能会被多次调用，因此应该是一个纯函数，它根据状态返回一个组件。
    - 