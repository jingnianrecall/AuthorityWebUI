<%@ WebHandler Language="C#" Class="bg_user" %>

using System;
using System.Web;
using System.Web.Security;

public class bg_user : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
        string action = context.Request.Params["action"];

        try
        {
            AuthorityMgmt.Model.User userFromCookie = AuthorityMgmt.Util.UserHelper.GetUser(context);   //获取cookie里的用户对象

            switch (action)
            {
                case "changepwd":
                    string ui_user_userchangepwd_originalpwd = context.Request.Params["ui_user_userchangepwd_originalpwd"] ?? "";
                    string ui_user_userchangepwd_newpwd = context.Request.Params["ui_user_userchangepwd_newpwd"] ?? "";

                    AuthorityMgmt.Model.User userChangePwd = new AuthorityMgmt.Model.User();
                    userChangePwd.Id = userFromCookie.Id;
                    userChangePwd.UserPwd = AuthorityMgmt.Util.Md5.GetMD5String(ui_user_userchangepwd_newpwd);   //md5加密

                    if (AuthorityMgmt.Util.Md5.GetMD5String(ui_user_userchangepwd_originalpwd) == userFromCookie.UserPwd)
                    {
                        if (new AuthorityMgmt.BLL.User().ChangePwd(userChangePwd))
                        {
                            FormsAuthentication.SignOut();    //这里如果不退出还得重写cookie

                            context.Response.Write("{\"msg\":\"修改成功，正在跳转到登陆页面！\",\"success\":true}");
                        }
                        else
                        {

                            context.Response.Write("{\"msg\":\"修改失败！\",\"success\":false}");
                        }
                    }
                    else
                    {

                        context.Response.Write("{\"msg\":\"原密码不正确！\",\"success\":false}");
                    }

                    break;
                case "getUserInfo":
                    context.Response.Write(new AuthorityMgmt.BLL.User().GetUserInfo(userFromCookie.Id));   //“我的信息”
                    break;
                case "search":
                    string strWhere = "1=1";
                    string sort = context.Request.Params["sort"];  //排序列
                    string order = context.Request.Params["order"];  //排序方式 asc或者desc
                    int pageindex = int.Parse(context.Request.Params["page"]);
                    int pagesize = int.Parse(context.Request.Params["rows"]);

                    string ui_user_userid = context.Request.Params["ui_user_userid"] ?? "";
                    string ui_user_username = context.Request.Params["ui_user_username"] ?? "";
                    string ui_user_isable = context.Request.Params["ui_user_isable"] ?? "";
                    string ui_user_description = context.Request.Params["ui_user_description"] ?? "";
                    string ui_user_adddatestart = context.Request.Params["ui_user_adddatestart"] ?? "";
                    string ui_user_adddateend = context.Request.Params["ui_user_adddateend"] ?? "";

                    if (ui_user_userid.Trim() != "" && !AuthorityMgmt.Util.SqlInjection.GetString(ui_user_userid))   //防止sql注入
                        strWhere += string.Format(" and UserId like '%{0}%'", ui_user_userid.Trim());
                    if (ui_user_username.Trim() != "" && !AuthorityMgmt.Util.SqlInjection.GetString(ui_user_username))
                        strWhere += string.Format(" and UserName like '%{0}%'", ui_user_username.Trim());
                    if (ui_user_description.Trim() != "" && !AuthorityMgmt.Util.SqlInjection.GetString(ui_user_description))
                        strWhere += string.Format(" and Description like '%{0}%'", ui_user_description.Trim());
                    if (ui_user_isable.Trim() != "select" && ui_user_isable.Trim() != "")
                        strWhere += " and IsAble = '" + ui_user_isable.Trim() + "'";
                    if (ui_user_adddatestart.Trim() != "")
                        strWhere += " and AddDate > '" + ui_user_adddatestart.Trim() + "'";
                    if (ui_user_adddateend.Trim() != "")
                        strWhere += " and AddDate < '" + ui_user_adddateend.Trim() + "'";

                    int totalCount;   //输出参数
                    string strJson = new AuthorityMgmt.BLL.User().GetPager("tbUser", "Id,UserId,UserName,IsAble,AddDate,Description", sort + " " + order, pagesize, pageindex, strWhere, out totalCount);
                    context.Response.Write("{\"total\": " + totalCount.ToString() + ",\"rows\":" + strJson + "}");

                    break;
                case "add":
                    if (userFromCookie != null && new AuthorityMgmt.BLL.Authority().IfAuthority("user", "add", userFromCookie.Id))
                    {
                        string ui_user_userid_add = context.Request.Params["ui_user_userid_add"] ?? "";
                        string ui_user_username_add = context.Request.Params["ui_user_username_add"] ?? "";
                        bool ui_user_isable_add = context.Request.Params["ui_user_isable_add"] == null ? false : true;
                        string ui_user_description_add = context.Request.Params["ui_user_description_add"] ?? "";

                        AuthorityMgmt.Model.User userAdd = new AuthorityMgmt.Model.User();
                        userAdd.UserId = ui_user_userid_add.Trim();
                        userAdd.UserName = ui_user_username_add.Trim();
                        userAdd.UserPwd = AuthorityMgmt.Util.Md5.GetMD5String("123");   //md5加密
                        userAdd.IsAble = ui_user_isable_add;
                        userAdd.Description = ui_user_description_add.Trim();

                        int userId = new AuthorityMgmt.BLL.User().AddUser(userAdd);
                        if (userId > 0)
                        {

                            context.Response.Write("{\"msg\":\"添加成功！\",\"success\":true}");
                        }
                        else
                        {
                            context.Response.Write("{\"msg\":\"添加失败！\",\"success\":false}");
                        }
                    }
                    else
                    {
                        context.Response.Write("{\"msg\":\"无权限，请联系管理员！\",\"success\":false}");
                    }
                    break;
                case "edit":
                    if (userFromCookie != null && new AuthorityMgmt.BLL.Authority().IfAuthority("user", "edit", userFromCookie.Id))
                    {
                        int id = Convert.ToInt32(context.Request.Params["id"]);
                        string originalName = context.Request.Params["originalName"] ?? "";
                        string ui_user_userid_edit = context.Request.Params["ui_user_userid_edit"] ?? "";
                        string ui_user_username_edit = context.Request.Params["ui_user_username_edit"] ?? "";
                        bool ui_user_isable_edit = context.Request.Params["ui_user_isable_edit"] == null ? false : true;
                        bool ui_user_ifchangepwd_edit = context.Request.Params["ui_user_ifchangepwd_edit"] == null ? false : true;
                        string ui_user_description_edit = context.Request.Params["ui_user_description_edit"] ?? "";

                        AuthorityMgmt.Model.User userEdit = new AuthorityMgmt.Model.User();
                        userEdit.Id = id;
                        userEdit.UserId = ui_user_userid_edit.Trim();
                        userEdit.UserName = ui_user_username_edit.Trim();
                        userEdit.IsAble = ui_user_isable_edit;
                        userEdit.Description = ui_user_description_edit.Trim();

                        if (new AuthorityMgmt.BLL.User().EditUser(userEdit, originalName))
                        {
                            context.Response.Write("{\"msg\":\"修改成功！\",\"success\":true}");
                        }
                        else
                        {
                            context.Response.Write("{\"msg\":\"修改失败！\",\"success\":false}");
                        }
                    }
                    else
                    {

                        context.Response.Write("{\"msg\":\"无权限，请联系管理员！\",\"success\":false}");
                    }

                    break;
                case "delete":
                    if (userFromCookie != null && new AuthorityMgmt.BLL.Authority().IfAuthority("user", "delete", userFromCookie.Id))
                    {
                            string idss = context.Request.Params["id"];
                        string ids = context.Request.Params["id"].Trim(',');
                        if (new AuthorityMgmt.BLL.User().DeleteUser(ids))
                        {

                            context.Response.Write("{\"msg\":\"删除成功！\",\"success\":true}");
                        }
                        else
                        {

                            context.Response.Write("{\"msg\":\"删除失败！\",\"success\":false}");
                        }
                    }
                    else
                    {

                        context.Response.Write("{\"msg\":\"无权限，请联系管理员！\",\"success\":false}");
                    }
                    break;
                case "setrole":
                    if (userFromCookie != null && new AuthorityMgmt.BLL.Authority().IfAuthority("user", "setrole", userFromCookie.Id))
                    {
                        string ui_user_setrole_userid = context.Request.Params["ui_user_setrole_userid"] ?? "";  //用户id，可能是多个
                        string ui_user_setrole_role = context.Request.Params["ui_user_setrole_role"] ?? "";  //角色id，可能是多个

                        if (ui_user_setrole_userid.IndexOf(",") == -1)  //单个用户分配角色
                        {
                            if (ui_user_setrole_userid != "" && new AuthorityMgmt.BLL.UserRole().SetRoleSingle(Convert.ToInt32(ui_user_setrole_userid), ui_user_setrole_role))
                            {

                                context.Response.Write("{\"msg\":\"设置成功！\",\"success\":true}");
                            }
                            else
                            {

                                context.Response.Write("{\"msg\":\"设置失败！\",\"success\":true}");
                            }
                        }
                        else   //批量设置用户角色
                        {
                            if (ui_user_setrole_userid != "" && new AuthorityMgmt.BLL.UserRole().SetRoleBatch(ui_user_setrole_userid, ui_user_setrole_role))
                            {

                                context.Response.Write("{\"msg\":\"设置成功！\",\"success\":true}");
                            }
                            else
                            {

                                context.Response.Write("{\"msg\":\"设置失败！\",\"success\":true}");
                            }
                        }
                    }
                    else
                    {

                        context.Response.Write("{\"msg\":\"无权限，请联系管理员！\",\"success\":false}");
                    }

                    break;
                default:
                    context.Response.Write("{\"msg\":\"参数错误！\",\"success\":false}");
                    break;
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"msg\":\"" + AuthorityMgmt.Util.JsonHelper.StringFilter(ex.Message) + "\",\"success\":false}");
        }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}