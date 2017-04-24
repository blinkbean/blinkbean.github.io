<%@page import="java.io.*"%>  
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%  
    String g_name = request.getParameter("g_name");
    String g_number = request.getParameter("g_number");
    String g_total = request.getParameter("g_total");
    String g_upper = request.getParameter("g_upper");
    String g_date = request.getParameter("g_date");
    String g_rate = request.getParameter("g_rate");

    String path = request.getContextPath();  
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/" +"gupiao";
    //获取绝对路径
    String filePath = request.getSession().getServletContext().getRealPath("/")+"gupiao"+"\\"; 
    String dataName = "data"+".json";
     
        try {
        BufferedWriter writer = new BufferedWriter (new OutputStreamWriter (new FileOutputStream (filePath+dataName,true),"UTF-8"));
        //FileWriter writer = new FileWriter(filePath+dataName,true,"utf-8");
        String str2 = g_name+",";
        String str3 = g_number+",";
        String str4 = g_total+",";
        String str5 = g_upper+",";
        String str6 = g_date+",";
        String str7 = g_rate;
        String str = str2+str3+str4+str5+str6+str7;
        writer.write(str+"\r\n");
        writer.close();
        } catch (IOException e) {
        e.printStackTrace();
        }  
        response.sendRedirect("add.html"); 
    %>  
</body>  
</html>  