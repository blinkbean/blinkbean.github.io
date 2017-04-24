<%@page import="java.io.BufferedReader"%>  
<%@page import="java.io.FileReader"%>  
<%@page import="java.io.*"%>
<%@page import="java.util.*"%> 
<%@page import="java.text.DecimalFormat"%>   
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>   
<!DOCTYPE>  
<html>  
<head>  
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">  
<title>jsp读取TXT格式文件</title>  
</head>  
<body>  
    <%  
        String filePath = "D:/"; 
        String dataName1 = "data11"+".json";
        String dataName = "data1"+".json";
        ArrayList<String> list = new ArrayList<String>(); 
        try{
        	File file = new File(filePath,dataName);
        	FileReader fr = new FileReader(file);  //字符输入流  
	        BufferedReader br = new BufferedReader(fr);  //使文件可按行读取并具有缓冲功能  
            BufferedWriter writer = new BufferedWriter (new OutputStreamWriter (new FileOutputStream (filePath+dataName1,true),"UTF-8"));
	        String str = br.readLine();
            String str7=""; 
	        while(str!=null){  
            String[] ss = str.split(",");
                
                String str1 = "qznamez:z"+ss[0]+"z,";
                String str2 = "znumberz:z"+ss[1]+"z,";
                String str3 = "ztotalz:z"+ss[2]+"z,";
                String str4 = "zupperz:z"+ss[3]+"z,";
                String str5 = "zdatez:z"+ss[4]+"z,";
                String str6 = "zratez:z"+ss[5]+"zp";
                str7 = str1+str2+str3+str4+str5+str6;
                       
            
            }writer.write(str7+"\r\n"); 
            writer.close();
            br.close();
            fr.close();
        }catch(Exception e){
			out.print(e);
        };  
    %>  
</body>  
</html>  