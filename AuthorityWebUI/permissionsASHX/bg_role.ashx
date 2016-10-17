<%@ WebHandler Language="C#" Class="bg_role" %>

using System;
using System.Web;

public class bg_role : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
            string action = context.Request.Params["action"];
            try
            {
                AuthorityMgmt.Model.User user = AuthorityMgmt.Util.UserHelper.GetUser(context);   //获取cookie里的用户对象

                switch (action)
                {
                    case "getall":
                        context.Response.Write(new AuthorityMgmt.BLL.Role().GetAllRole("1=1"));
                        break;
                    case "search":
                        string strWhere = "1=1";
                        string sort = context.Request.Params["sort"];  //排序列
                        string order = context.Request.Params["order"];  //排序方式 asc或者desc
                        int pageindex = int.Parse(context.Request.Params["page"]);
                        int pagesize = int.Parse(context.Request.Params["rows"]);

                        int totalCount;   //输出参数
                        string strJson = new AuthorityMgmt.BLL.Role().GetPager("tbRole", "Id,RoleName,AddDate,ModifyDate,Description", sort + " " + order, pagesize, pageindex, strWhere, out totalCount);
                        context.Response.Write("{\"total\": " + totalCount.ToString() + ",\"rows\":" + strJson + "}");
                        break;
                    case "searchRoleUser":
                        int roleUserId = int.Parse(context.Request.Params["roleId"]);
                        string sortRoleUser = context.Request.Params["sort"];  //排序列
                        string orderRoleUser = context.Request.Params["order"];  //排序方式 asc或者desc
                        int pageindexRoleUser = int.Parse(context.Request.Params["page"]);
                        int pagesizeRoleUser = int.Parse(context.Request.Params["rows"]);

                        string strJsonRoleUser = new AuthorityMgmt.BLL.Role().GetPagerRoleUser(roleUserId, sortRoleUser + " " + orderRoleUser, pagesizeRoleUser, pageindexRoleUser);
                        context.Response.Write(strJsonRoleUser);
                        break;
                    case "add":
                        if (user != null && new AuthorityMgmt.BLL.Authority().IfAuthority("role", "add", user.Id))
                        {
                            string ui_role_rolename_add = context.Request.Params["ui_role_rolename_add"] ?? "";
                            string ui_role_description_add = context.Request.Params["ui_role_description_add"] ?? "";

                            AuthorityMgmt.Model.Role roleAdd = new AuthorityMgmt.Model.Role();
                            roleAdd.RoleName = ui_role_rolename_add;
                            roleAdd.Description = ui_role_description_add.Trim();

                            int roleId = new AuthorityMgmt.BLL.Role().AddRole(roleAdd);
                            if (roleId > 0)
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
                        if (user != null && new AuthorityMgmt.BLL.Authority().IfAuthority("role", "edit", user.Id))
                        {
                            int id = Convert.ToInt32(context.Request.Params["id"]);
                            string originalName = context.Request.Params["originalName"] ?? "";
                            string ui_role_rolename_edit = context.Request.Params["ui_role_rolename_edit"] ?? "";
                            string ui_role_description_edit = context.Request.Params["ui_role_description_edit"] ?? "";

                            AuthorityMgmt.Model.Role roleEdit = new AuthorityMgmt.Model.Role();
                            roleEdit.Id = id;
                            roleEdit.RoleName = ui_role_rolename_edit;
                            roleEdit.Description = ui_role_description_edit.Trim();

                            if (new AuthorityMgmt.BLL.Role().EditRole(roleEdit, originalName))
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
                        if (user != null && new AuthorityMgmt.BLL.Authority().IfAuthority("role", "delete", user.Id))
                        {
                            int id = Convert.ToInt32(context.Request.Params["id"]);
                            if (new AuthorityMgmt.BLL.Role().DeleteRole(id))
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
                    case "authorize":
                        if (user != null && new AuthorityMgmt.BLL.Authority().IfAuthority("role", "authorize", user.Id))
                        {
                            int roleId = Convert.ToInt32(context.Request.Params["roleId"]);    //要授权的角色id
                            string menuButtonId = context.Request.Params["menuButtonId"].Trim(',');   //具体的菜单和按钮权限
                            if (new AuthorityMgmt.BLL.Role().Authorize(roleId, menuButtonId))
                            {
                                context.Response.Write("{\"msg\":\"授权成功！\",\"success\":true}");
                            }
                            else
                            {
                                context.Response.Write("{\"msg\":\"授权失败！\",\"success\":false}");
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