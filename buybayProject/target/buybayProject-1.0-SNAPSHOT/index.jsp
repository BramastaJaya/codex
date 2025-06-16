<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page language="java" %>
<%response.sendRedirect("index.html");%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <form method="get" action="javaServlet">
        NIM: <input type="text" name="nim"/> <br />
        Nama: <input type="text" name="nama"/> <br />
        <input type="submit" value="Kirim"/>
    </form>
    <% 
       out.print(request.getAttribute("nim")+"<br />");
       out.print(request.getAttribute("nama")+"<br />");
    %>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>BuyBay</title>
    </head>
    <body>
        <h1>Hello This is a test for our new project java web development</h1>
    </body>
</html>
