class API {
  // -------------------------------------------------------------
  // 1. BASE URL (Check your IP via ipconfig if it fails)
  // -------------------------------------------------------------
  static const hostConnect = "http://192.168.100.7/connection";

  // -------------------------------------------------------------
  // 2. AUTHENTICATION (Files are directly in 'connection' folder)
  // -------------------------------------------------------------
  static const signup = "$hostConnect/signup.php";
  static const login = "$hostConnect/login.php";
  static const searchProduct = "$hostConnect/search_product.php";
  static const getSellerProducts = "$hostConnect/get_seller_products.php";
  static const editProduct = "$hostConnect/edit_product.php";
  static const getMyOrders = "$hostConnect/get_my_orders.php";
  // Forgot Password / OTP
  static const validateEmail =
      "$hostConnect/send_otp.php"; // Linked to PHPMailer
  static const resetPassword =
      "$hostConnect/reset_password.php"; // Linked to DB Update

  // -------------------------------------------------------------
  // 3. ADMIN PANEL
  // -------------------------------------------------------------

  static const deleteProduct = "$hostConnect/admin/delete_product.php";
  static const getAdminStats = "$hostConnect/admin/get_stats.php";
  static const getAllUsers = "$hostConnect/admin/get_all_users.php";
  static const deleteUser = "$hostConnect/admin/delete_user.php";
  static const getAllProductsAdmin =
      "$hostConnect/admin/get_all_products_admin.php";
  static const getAllOrdersAdmin = "$hostConnect/admin/get_all_orders.php";
  static const uploadProfilePic = "$hostConnect/upload_profile_pic.php";
  static const updateProfile = "$hostConnect/update_profile.php";

  // -------------------------------------------------------------
  // 4. PRODUCTS
  // -------------------------------------------------------------
  static const addProduct = "$hostConnect/add_product.php";
  static const getSellerStats = "$hostConnect/get_seller_stats.php";
  static const getByCategory = "$hostConnect/get_by_category.php";
  static const getProducts = "$hostConnect/get_products.php";
  static const addToCart = "$hostConnect/add_to_cart.php";
  static const getCart = "$hostConnect/get_cart.php";
  static const deleteCart = "$hostConnect/delete_cart.php";
  static const updateCart = "$hostConnect/update_cart.php";
  static const placeOrder = "$hostConnect/place_order.php";
  static const toggleFavorite = "$hostConnect/toggle_favorite.php";
  static const getFavorite = "$hostConnect/get_favorite.php";
  // static const getOrders = "$hostConnect/get_orders.php";
}
