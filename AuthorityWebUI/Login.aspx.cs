using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace AuthorityWebUI
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        protected void btn_Login_Click(object sender, EventArgs e)
        {
            string userName = username.Text.Trim();
            string userPassword = AuthorityMgmt.Util.Md5.GetMD5String(password.Text.Trim());

            AuthorityMgmt.Model.User currentUser = new AuthorityMgmt.BLL.User().UserLogin(userName, userPassword);
            if (currentUser == null)
            {
                Response.Write("{\"msg\":\"用户名或密码错误！\",\"success\":false}");

            }
            else if (currentUser.IsAble == false)
            {
                Response.Write("{\"msg\":\"用户已被禁用！\",\"success\":false}");

            }
            else
            {
                Response.Write("{\"msg\":\"登录成功！\",\"success\":true}");

                DateTime dateCookieExpires = DateTime.Now.AddDays(1);  //cookie有效期

                FormsAuthenticationTicket ticket = new FormsAuthenticationTicket
                (
                    2,
                    currentUser.UserId,
                    DateTime.Now,
                    dateCookieExpires,
                    false,
                    new JavaScriptSerializer().Serialize(currentUser)  //序列化当前用户对象
                );
                string encTicket = FormsAuthentication.Encrypt(ticket);
                HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, encTicket);
                if (dateCookieExpires != new DateTime(9999, 12, 31))    //不是默认时间才设置过期时间，否则会话cookie
                    cookie.Expires = dateCookieExpires;
                Response.Cookies.Add(cookie);

                Response.Redirect("PermissionsManage.html");
            }
        }
    }
}