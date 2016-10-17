<%@ WebHandler Language="C#" Class="bg_menu" %>

using System;
using System.Web;

public class bg_menu : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
            string action = context.Request.Params["action"];
            try
            {
                AuthorityMgmt.Model.User user = AuthorityMgmt.Util.UserHelper.GetUser(context);   //获取cookie里的用户对象

                switch (action)
                {
                    case "getUserMenu":  //获取特定用户能看到的菜单（左侧树）
                        context.Response.Write(new AuthorityMgmt.BLL.Menu().GetUserMenu(user.Id));
                        break;
                    case "getAllMenu":   //根据角色id获取此角色有的权限（设置角色时自动勾选已经有的按钮权限）
                        int roleid = Convert.ToInt32(context.Request.Params["roleid"]);  //角色id
                        context.Response.Write(new AuthorityMgmt.BLL.Menu().GetAllMenu(roleid));
                        break;
                    case "getMyAuthority":  //前台根据用户名查“我的权限”
                        context.Response.Write(new AuthorityMgmt.BLL.Menu().GetMyAuthority(user.Id));
                        break;
                    case "search":
                        string strWhere = "1=1";
                        string sort = context.Request.Params["sort"] == null ? "Id" : context.Request.Params["sort"];  //排序列
                        string order = context.Request.Params["order"] == null ? "asc" : context.Request.Params["order"];  //排序方式 asc或者desc
                        int pageindex = int.Parse(context.Request.Params["page"]);
                        int pagesize = int.Parse(context.Request.Params["rows"]);

                        int totalCount;   //输出参数
                        string strJson = "";    //输出结果
                        if (order.IndexOf(',') != -1)   //如果有","就是多列排序（不能拿列判断，列名中间可能有","符号）
                        {
                            //多列排序：
                            //sort：ParentId,Sort,AddDate
                            //order：asc,desc,asc
                            string sortMulti = "";  //拼接排序条件，例：ParentId desc,Sort asc
                            string[] sortArray = sort.Split(',');   //列名中间有","符号，这里也要出错。正常不会有
                            string[] orderArray = order.Split(',');
                            for (int i = 0; i < sortArray.Length; i++)
                            {
                                sortMulti += sortArray[i] + " " + orderArray[i] + ",";
                            }
                            strJson = new AuthorityMgmt.BLL.Menu().GetPager("tbMenu", "Id,Name,ParentId,Code,LinkAddress,Icon,Sort,AddDate", sortMulti.Trim(','), pagesize, pageindex, strWhere, out totalCount);
                        }
                        else
                        {
                            strJson = new AuthorityMgmt.BLL.Menu().GetPager("tbMenu", "Id,Name,ParentId,Code,LinkAddress,Icon,Sort,AddDate", sort + " " + order, pagesize, pageindex, strWhere, out totalCount);
                           
                        }

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