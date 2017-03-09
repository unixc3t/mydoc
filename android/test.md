#####  android  Testing Support Library 组成

      Instrumenttaation
              |
              |
     androidJuniRunner   <-----并入---  UiAutomator
              |
              |
       ----------------
       |              |
     白盒与UI        黑盒与ui
       |              |
     Espresso       Uiautomator

> andoridJunitRunner类是一个junit运行器，可以在你的设备上运行Junt3或者junit4风格的测试代码，执行步骤如下

* 加载你的测试包和应用
* 运行你的测试
* 输出测试结果


> andoridJUniRunner类替换了InstrementationTestRunner类，因为InstrementationTestRunner类只能提供junit3的测试
> 使用Junt4，需要使用@Runwith(AndroidJunit4.class)

    @RunWith(AndroidJunit4.class)
    @SdkSuppress(minSdkVersion = 18)
    public class UiTest {

      UiDevice device;
      @Before
      public void setUp() {
        device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
      }

      @Test 
      public void testLock() throws Remotexception {

        device.sleep();
        device.wakeUp();

      }

    }

#####  测试过滤
* @RequireDevice: 制定测试只运行在物理设备而不运行在模拟器
* @SdkSupress: 限制运行在制定的安卓版本上,例如 @SSKSupress(MinSdkVersion=18)
* @Smalltest @MediumTest @LargeTest 按照用例重视成都进行分类测试

##### 测试切片

* -e numShard 数量 指定要创建的切片
* -e shardIndexoption ID 指定要运行的切片

> 例如 

    adb shell am instrument -w -e numshards 10 -e shardIndex 2
    # 分成10个切片，运行二滴个切片


#### espresso

> espresso 是一个白盒风格的测试框架

    onView(ViewMather).perform(ViewAction).check(ViewAssertion); //常规组件测试
    onData(ObjectMatcher).DataOptions.perform(ViewAction).check(ViewAssertion); //adapter测试
    onView(withId(R.id.changeTextBt)).perform(click()); //测试点击按钮提交文本

#### UIAutomator测试框架，适合写黑河box-style风格的自动化测试 
* 查看布局层次结构
* 一个api来检索信息状态
* 支持深度ui测试


##### 使用测试支持库的步骤

* class上加运行期器
* 添加测试方法
    @RunWith(AndroidJunit4.class)
    public class {
        @Test
        public void pressKey(){}
    }
