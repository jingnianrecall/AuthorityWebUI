$(function () {
    initLogin();
})

function initLogin() {
    $('#treeLeft').tree({    //初始化左侧功能树（不同用户显示的树是不同的）
        method: 'GET',
        url: 'permissionsASHX/bg_menu.ashx?action=getUserMenu',
        lines: true,
        onClick: function (node) {    //点击左侧的tree节点  打开右侧tabs显示内容
            if (node.attributes) {
                addTab(node.text, node.attributes.url, node.iconCls);
            }
        }
    });
}

function addTab(subtitle, url, icon) {
    if (!$('#tabs').tabs('exists', subtitle)) {
        $('#tabs').tabs('add', {
            title: subtitle,
            href: url,
            iconCls: icon,
            closable: true,
            loadingMessage: '正在加载中......'
        });
    } else {
        $('#tabs').tabs('select', subtitle);
    }
}

function refreshTab() {
    var index = $('#tabs').tabs('getTabIndex', $('#tabs').tabs('getSelected'));
    if (index != -1) {
        $('#tabs').tabs('getTab', index).panel('refresh');
    }
}

function closeTab() {
    $('.tabs-inner span').each(function (i, n) {
        var t = $(n).text();
        if (t != '') {
            $('#tabs').tabs('close', t);
        }
    });
}

function returnHome() {
    window.location.href = "index.html";
}

//查看当前用户信息
function searchMyInfo() {
    $("<div/>").dialog({
        id: "ui_myinfo_dialog",
        href: "permissionsHTML/ui_myinfo.html",
        title: "我的信息",
        height: 500,
        width: 580,
        modal: true,
        onLoad: function () {
            $.ajax({
                url: "permissionsASHX/bg_user.ashx?action=getUserInfo&timespan=" + new Date().getTime(),
                type: "post",
                dataType: "json",
                success: function (result) {
                    $("#ui_myinfo_userid").html(result[0].UserId);
                    $("#ui_myinfo_username").html(result[0].UserName);
                    $("#ui_myinfo_adddate").html(result[0].AddDate);
                    $("#ui_myinfo_roles").html(result[0].RoleName.length > 12 ? "<span title=" + result[0].RoleName + ">" + result[0].RoleName.substring(0, 12) + "...</span>" : result[0].RoleName);
                    $("#ui_myinfo_departments").html(result[0].DepartmentName.length > 12 ? "<span title=" + result[0].DepartmentName + ">" + result[0].DepartmentName.substring(0, 12) + "...</span>" : result[0].DepartmentName);
                    //长度超过12个字符就隐藏
                }
            });

            $('#ui_myinfo_authority').tree({
                url: "permissionsASHX/bg_menu.ashx?action=getMyAuthority&timespan=" + new Date().getTime(),
                onlyLeafCheck: true,
                checkbox: true
            });
        },
        onClose: function () {
            $("#ui_myinfo_dialog").dialog('destroy');  //销毁dialog对象
        }
    });
}

//修改密码
function changePwd() {
    $("<div/>").dialog({
        id: "ui_user_userchangepwd_dialog",
        href: "permissionsHTML/ui_user_changepwd.html",
        title: "修改密码",
        height: 240,
        width: 380,
        modal: true,
        closable: false,
        buttons: [{
            id: "ui_user_userchangepwd_edit",
            text: '修 改',
            handler: function () {
                $("#ui_user_userchangepwd_form").form("submit", {
                    url: "permissionsASHX/bg_user.ashx",
                    onSubmit: function (param) {
                        $('#ui_user_userchangepwd_edit').linkbutton('disable');  //点击就不可用，防止连击
                        param.action = 'changepwd';
                        if ($(this).form('validate'))
                            return true;
                        else {
                            $('#ui_user_userchangepwd_edit').linkbutton('enable');   //恢复按钮
                            return false;
                        }
                    },
                    success: function (data) {
                        $('#ui_user_userchangepwd_edit').linkbutton('enable');   //恢复按钮
                        var dataBack = $.parseJSON(data);    //序列化成对象
                        if (dataBack.success) {
                            //$("#ui_user_userchangepwd_dialog").dialog('destroy');  //销毁dialog对象
                            //$.show_warning("提示", dataBack.msg);
                            alert(dataBack.msg);
                            window.location.href = "login.html";
                        }
                        else {
                            $('#ui_user_userchangepwd_edit').linkbutton('enable');
                            $.show_warning("提示", dataBack.msg);
                        }
                    }
                });
            }
        }, {
            text: '取 消',
            handler: function () { $("#ui_user_userchangepwd_dialog").dialog('destroy'); }
        }],
        onLoad: function () {
            $("#ui_user_userchangepwd_originalpwd").focus();
        }
    });
}
