<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="AuthorityWebUI.Login" %>

<!DOCTYPE html>
<html>
  <head>
    <title>Admin Login</title>
    <!-- Bootstrap -->
    <link href="css/bootstrap3.min.css" rel="stylesheet" media="screen">
    <link href="css/bootstrap-responsive.min.css" rel="stylesheet" media="screen">
    <link href="assets/styles.css" rel="stylesheet" media="screen">
     <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
    <script src="js/vendor/modernizr-2.6.2-respond-1.1.0.min.js"></script>
  </head>
  <body id="login">
    <div class="container">

      <form class="form-signin" runat ="server">
        <h2 class="form-signin-heading">Please sign in</h2>
        <asp:textbox runat ="server" type="text" id="username" class="input-block-level" placeholder="UserName"></asp:textbox>
        <asp:textbox runat ="server" type="password" id="password" class="input-block-level" placeholder="Password"></asp:textbox>
        <label class="checkbox">
          <input type="checkbox" value="remember-me"> Remember me
        </label>
        <asp:button runat ="server" class="btn btn-large btn-primary" type="submit" Text ="Sign in" OnClick ="btn_Login_Click" ></asp:button>
      </form>

    </div> <!-- /container -->
    <script src="vendors/jquery-1.9.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
  </body>
</html>


