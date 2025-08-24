import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';



/*Widget buildArticleItem(article , context) => InkWell(
  onTap: ()
  {
    navigateTo(context, WebviewScreen(
      articleUrl: '${article['url']}',
    ));
  },
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      children: [
        Container(
          width: 120.0,
          height: 120.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: NetworkImage('${article['urlToImage']}'),
                fit: BoxFit.cover,

              )
          ),
        ),
        SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: Container(
            height: 120.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children:
              [
                Expanded(
                  child: Text(
                    '${article['title']} ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines:3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${article['publishedAt']}',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    ),
  ),
);*/
Widget myDividor () =>  Padding(
  padding: const EdgeInsetsDirectional.only(
    start: 20.0,),
  child: Container
    (
    width: double.infinity,
    height: 1.0,
    color: Colors.grey[300],
  ),
);
/*Widget articleBuilder(List , context , {isSearch = false}) => AnimatedConditionalBuilder(
  condition: List.length > 0,
  builder: (context) => ListView.separated(
    physics: BouncingScrollPhysics(),
    itemBuilder: (context , index) => buildArticleItem(List[index], context),
    separatorBuilder: (context , index) => myDividor(),
    itemCount: 10,
  ),
  fallback: (context) => isSearch? Container() : Center(child: CircularProgressIndicator()),
);*/

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpperCase = true,
  required VoidCallback function,
  required String text, Color? color,
  Color? textColor,
}) =>
    Container(
      width: width,
      height: 40.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: background,
      ),
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
Widget defaultFormField({
  required BuildContext context,
  required TextEditingController controller,
  required TextInputType type,
  required FormFieldValidator<String> validate,
  required String label,
  required IconData prefix,
  bool readOnly = false,
  IconData? suffix,
  bool isPassword = false,
  VoidCallback? suffixPressed,
  ValueChanged<String>? onSubmitted, // Optional callback for onSubmitted
  ValueChanged<String>? onChanged,
  VoidCallback? onTap, required obsecure, // Optional callback for onChanged
  Color? textColor,
  Color? iconColor,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      validator: validate,
      onTap: onTap,
      obscureText: isPassword,
      readOnly: readOnly,
      style: TextStyle(color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color),
        prefixIcon: Icon(prefix, color: iconColor ?? Theme.of(context).iconTheme.color),
        suffixIcon: suffix != null
            ? IconButton(
          onPressed: suffixPressed,
          icon: Icon(suffix, color: iconColor ?? Theme.of(context).iconTheme.color),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: iconColor ?? Theme.of(context).iconTheme.color ?? Colors.blue, width: 2.0),
        ),
      ),
    );
void navigateTo(context , widget) => Navigator.push(
  context,
  MaterialPageRoute(
      builder: (context) => widget

  ) ,
);

void navigateAndFinish(
    context ,
    widget
    ) => Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (context) => widget,)
  ,
      (Route<dynamic> route) => false,
);
Widget defaultTextButton({
  required VoidCallback function,
  required String text,
  Color color = Colors.blue,
  Color textColor = Colors.blue,
  Color backgroundColor = Colors.transparent,
  Color foregroundColor = Colors.transparent,
}) =>
    TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
        foregroundColor: WidgetStateProperty.all<Color>(foregroundColor),

      ),
      onPressed: function,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );



void showToast({
  required String text,
  required ToastStates state,
}) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 5,
    backgroundColor: chooseToastColor(state),
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state)
{
  Color color;
  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }
  return color;
}


/*
Widget buildListProduct(model, context, {bool isSearch = true}) => Padding(
  padding: const EdgeInsets.all(10.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start, // ensures alignment from top
    children: [
      Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          Image(
            image: (model.image != null && model.image.isNotEmpty)
                ? NetworkImage(model.image)
                : const AssetImage('assets/images/default.png') as ImageProvider,
            height: 120.0,
            width: 120.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 120,
              height: 120,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
          if (model.discount != 0)
            Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: const Text(
                "DISCOUNT",
                style: TextStyle(color: Colors.white, fontSize: 10.0),
              ),
            ),
        ],
      ),
      const SizedBox(width: 10.0),
      Expanded(
        child: Container(
          height: 120.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${model.name}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.3, fontSize: 14.0),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${model.price}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: defaultColor,
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  if (model.discount != 0)
                    Text(
                      '${model.oldPrice}',
                      style: const TextStyle(
                        fontSize: 10.0,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        ShopCubit.get(context).changeFavorites(model.id!);
                      },
                      icon: CircleAvatar(
                        radius: 15.0,
                        backgroundColor: ShopCubit.get(context).favorites[model.id!]!
                            ? defaultColor
                            : Colors.grey,
                        child: const Icon(
                          Icons.favorite_border,
                          size: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);

Widget buildCartProduct(CartProduct model, context, int? cartItemId, {bool isSearch = true} ) => Padding(

  padding: const EdgeInsets.all(10.0),
  child: Material(
    child: IntrinsicHeight(
      child: Container(

        decoration: BoxDecoration(
          color: ShopCubit.get(context).isDark ? Colors.white : Colors.grey[800],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                Image(
                  image: NetworkImage(model.image),
                  height: 120.0,
                  width: 120.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
                if (model.discount != 0)
                  Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: const Text(
                      "DISCOUNT",
                      style: TextStyle(color: Colors.white, fontSize: 10.0),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model.name}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(height: 1.3, fontSize: 14.0),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(

                        onPressed: ()
                        {
                          if (model.quantity > 1) {
                            ShopCubit.get(context).updateCartQuantity( productId: cartItemId! , quantity: model.quantity - 1);


                          }else
                          {
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                              msg: 'There is 1 item already',
                            );
                          }
                        },
                        icon: Icon(Icons.remove),
                      ),
                      Text(
                        '${model.quantity}',
                        style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                      IconButton(
                        onPressed: ()
                        {
                          ShopCubit.get(context).updateCartQuantity( productId: cartItemId! , quantity: model.quantity + 1);
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${model.price * model.quantity}' ,
                        style: TextStyle(fontSize: 14.0, color: defaultColor),
                      ),
                      const SizedBox(width: 5.0),
                      if (model.discount != 0)
                        Text(
                          '${model.oldPrice}',
                          style: const TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          if (cartItemId != null) {
                            ShopCubit.get(context).changeCart(cartItemId);
                          } else {
                            print("Error: cartItemId is null");
                          }
                        },
                        icon: CircleAvatar(
                          radius: 15.0,
                          backgroundColor:
                          (ShopCubit.get(context).cart[model.id] ?? false)
                              ? Colors.grey
                              : Colors.grey,
                          child:  Icon(
                            (ShopCubit.get(context).cart[model.id] ?? false)
                                ? Icons.shopping_cart
                                : Icons.remove_shopping_cart,
                            size: 14.0,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);


*/
PreferredSizeWidget defaultAppBar({
  required BuildContext context,
  String title = '',
  List<Widget>? actions,
}) => AppBar(
  leading: IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: const Icon(Icons.arrow_back),
  ),
  title: Text(title),
  titleSpacing: 5.0,
  actionsPadding: const EdgeInsetsDirectional.only(end: 10.0),
  actions: actions,
);
