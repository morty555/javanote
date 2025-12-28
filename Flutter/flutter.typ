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
