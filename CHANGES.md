## تغییرات اعمال شده برای حذف پارامتر `rq` از کنترلرها

### خلاصه تغییرات

در این پروژه، تمام کنترلرها و کلاس‌های مرتبط بروزرسانی شدند تا به جای پاس کردن `rq` به عنوان پارامتر، از یک سیستم `RequestContext` سراسری استفاده کنند.

### تغییرات اصلی

#### 1. ایجاد RequestContext
- کلاس `RequestContext` در `lib/src/core/request_context.dart` ایجاد شد
- از Zone-based context برای نگهداری thread-safe request استفاده می‌کند
- متد `RequestContext.current` برای دسترسی سراسری به WebRequest فراهم می‌کند

#### 2. بروزرسانی WaController
- حذف پارامتر `rq` از constructor
- اضافه کردن getter `rq` که از `RequestContext.current` استفاده می‌کند

#### 3. بروزرسانی WaServer
- اضافه کردن `RequestContext.run()` در هندلر request‌ها
- تنظیم request context در ابتدای هر request

#### 4. بروزرسانی کنترلرها
- `HomeController`: حذف پارامتر `rq` از constructor
- `AuthController`: حذف پارامتر `rq` از constructor  
- `HtmlerController`: حذف پارامتر `rq` از constructor
- `WaApiController`: حذف پارامتر `rq` از constructor
- `IncludeJsController`: حذف پارامتر `rq` از constructor

#### 5. بروزرسانی کلاس‌های کمکی
- `FormValidator`: حذف پارامتر `rq` و استفاده از RequestContext
- `WaView`: حذف پارامتر `rq` و استفاده از RequestContext
- `UIPaging`: حذف پارامتر `rq` و استفاده از RequestContext

#### 6. بروزرسانی Routing
- حذف پاس کردن `rq` به کنترلرها در instantiation
- تبدیل inline functions به controller methods

### مزایای این تغییرات

1. **سادگی کد**: دیگر نیازی به پاس کردن `rq` در همه جا نیست
2. **کاهش تکرار**: حذف کد تکراری پاس کردن پارامتر
3. **Thread Safety**: استفاده از Zone-based context تضمین thread safety
4. **دسترسی ساده**: دسترسی آسان و سراسری به WebRequest

### نحوه استفاده

#### قبل از تغییرات:
```dart
class MyController extends WaController {
  MyController(super.rq);
  
  Future<String> myMethod() async {
    return rq.renderString(text: "Hello");
  }
}

// در routing:
final controller = MyController(rq);
```

#### بعد از تغییرات:
```dart
class MyController extends WaController {
  MyController();
  
  Future<String> myMethod() async {
    return rq.renderString(text: "Hello"); // همچنان از rq استفاده می‌شود
  }
}

// در routing:
final controller = MyController(); // دیگر نیازی به پاس کردن rq نیست
```

### نکات مهم

- تمام API های موجود کماکان کار می‌کنند
- `rq` همچنان در کنترلرها قابل دسترسی است
- هیچ تاثیری بر عملکرد سیستم ندارد
- تغییرات backward compatible هستند

### Export جدید

کلاس `RequestContext` به `wa_route.dart` اضافه شده تا در دسترس باشد:

```dart
export 'src/core/request_context.dart';
```