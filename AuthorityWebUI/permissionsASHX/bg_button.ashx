<%@ WebHandler Language="C#" Class="bg_button" %>

using System;
using System.Web;
using System.Data;

public class bg_button : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
            context.Response.ContentType = "application/json";
            string action = context.Request.Params["action"];

            try
            {
                AuthorityMgmt.Model.User user = AuthorityMgmt.Util.UserHelper.GetUser(context);   //获取cookie里的用户对象

                switch (action)
                {
                    case "getbutton":   //根据用户的权限获取用户点击的菜单有权限的按钮
                        string pageName = context.Request.Params["pagename"];
                        string menuCode = context.Request.Params["menucode"];   //菜单标识码
                        DataTable dt = new AuthorityMgmt.BLL.Button().GetButtonByMenuCodeAndUserId(menuCode, user.Id);
                        context.Response.Write(AuthorityMgmt.Util.ToolbarHelper.GetToolBar(dt, pageName));

                        break;
                    case "search":
                        string strWhere = "1=1";
                        string sort = context.Request.Params["sort"];  //排序列
                        string order = context.Request.Params["order"];  //排序方式 asc或者desc
                        int pageindex = int.Parse(context.Request.Params["page"]);
                        int pagesize = int.Parse(context.Request.Params["rows"]);

                        int totalCount;   //输出参数
                        string strJson = new AuthorityMgmt.BLL.Button().GetPager("tbButton", "Id,Name,Code,Icon,Sort,AddDate,Description", sort + " " + order, pagesize, pageindex, strWhere, out totalCount);
                        context.Response.Write("{\"total\": " + totalCount.ToString() + ",\"rows\":" + strJson + "}");

                        break;
                    default:
                        context.Response.Write("{\"result\":\"参数错误！\",\"success\":false}");
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