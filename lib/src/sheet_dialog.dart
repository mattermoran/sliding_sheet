part of 'sheet.dart';

/// Shows a [SlidingSheet] as a material design bottom sheet.
///
/// The `builder` parameter must not be null and is used to construct a [SlidingSheetDialog].
///
/// The `parentBuilder` parameter can be used to wrap the sheet inside a parent, for example a
/// [Theme] or [AnnotatedRegion].
///
/// The `routeSettings` argument, see [RouteSettings] for details.
///
/// The `resizeToAvoidBottomInset` parameter can be used to avoid the keyboard from obscuring
/// the content bottom sheet.
Future<T?> showSlidingBottomSheet<T>(
  BuildContext context, {
  required SlidingSheet Function(BuildContext context) builder,
  Widget Function(BuildContext context, SlidingSheet sheet)? parentBuilder,
  RouteSettings? routeSettings,
  bool useRootNavigator = false,
  bool resizeToAvoidBottomInset = true,
}) {
  SlidingSheet dialog = builder(context);

  final SheetController controller = dialog.controller ?? SheetController();
  final ValueNotifier<int> rebuilder = ValueNotifier(0);

  return Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  ).push(
    _SheetRoute(
      duration: dialog.duration,
      settings: routeSettings,
      builder: (context, animation, route) {
        return ValueListenableBuilder(
          valueListenable: rebuilder,
          builder: (context, dynamic value, _) {
            dialog = builder(context);

            // Assign the rebuild function in order to
            // be able to change the dialogs parameters
            // inside a dialog.
            controller._rebuild = () {
              rebuilder.value++;
            };

            Widget sheet = dialog;

            if (parentBuilder != null) {
              sheet = parentBuilder(context, sheet as SlidingSheet);
            }

            if (resizeToAvoidBottomInset) {
              sheet = Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: sheet,
              );
            }

            return sheet;
          },
        );
      },
    ),
  );
}

/// A transparent route for a bottom sheet dialog.
class _SheetRoute<T> extends PageRoute<T> {
  final Widget Function(BuildContext, Animation<double>, _SheetRoute<T>) builder;
  final Duration duration;
  _SheetRoute({
    required this.builder,
    required this.duration,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          fullscreenDialog: false,
        );

  static Route? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<_RouteHost>()?.route;
  }

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _RouteHost(
      route: this,
      child: builder(context, animation, this),
    );
  }
}

class _RouteHost extends StatelessWidget {
  final Route route;
  final Widget child;
  const _RouteHost({
    Key? key,
    required this.route,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}
