<%@page import="java.nio.file.Paths"%>
<%@page import="java.nio.file.Path"%>
<%@page import="java.util.stream.Collectors"%>
<%@page import="java.util.stream.Collector"%>
<%@page import="com.model.MainMethod"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.util.regex.Matcher"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,javax.servlet.*"%>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@ page import="org.apache.commons.io.output.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css"
	integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh"
	crossorigin="anonymous">
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css"
	integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh"
	crossorigin="anonymous">
<link href="https://fonts.googleapis.com/icon?family=Material+Icons"
	rel="stylesheet">

<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js"
	integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n"
	crossorigin="anonymous"></script>
<script
	src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js"
	integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo"
	crossorigin="anonymous"></script>
<script
	src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"
	integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6"
	crossorigin="anonymous"></script>
<title>Code Quality Measure</title>
<style>
table, td, th {
	border: 1px solid black;
}
table {
	border-collapse: collapse;
	width: 100%;
}
th {
	height: 50px;
}

ul {
	list-style-type: none;
	margin: 0;
	padding: 0;
	overflow: hidden;
	background-color: #2c2e2d;
	font-size: 25px;
}
li {
	float: left;
}
li a {
	display: block;
	color: white;
	text-align: center;
	padding: 14px 16px;
	text-decoration: none;
}
li
a:hover:not (.active ) {
	background-color: #f2f5f4;
}
</style>
</head>
<body  style="border-color: #454d55;">
<ul>
		<li><a href="index.jsp">Home</a></li>
		</ul>

	<div >
		<%
			String currentClassName = "";
			File file = null;
			int maxFileSize = 5000 * 1004;
			int maxMemSize = 5000 * 1004;
			//D Drive is used as the file path 
			String filePath = "D:/";
			
			Path root = Paths.get(".").normalize().toAbsolutePath();
			String path = root.toAbsolutePath().toString();

			List<File> fileList = new ArrayList();

			String contentType = request.getContentType();
			if ((contentType.indexOf("multipart/form-data") >= 0)) {

				DiskFileItemFactory factory = new DiskFileItemFactory();
				factory.setSizeThreshold(maxMemSize);
				//  factory.setRepository(new File("c:\\text"));
				ServletFileUpload upload = new ServletFileUpload(factory);
				upload.setSizeMax(maxFileSize);
				try {
			List fileItems = upload.parseRequest(request);
			Iterator i = fileItems.iterator();
			out.println("<h1>Uploaded Files</h1>");
			//out.println("<hr>");
			while (i.hasNext()) {
				FileItem fi = (FileItem) i.next();
				if (!fi.isFormField()) {
			String fieldName = fi.getFieldName();
			String fileName = fi.getName();

			boolean isInMemory = fi.isInMemory();
			long sizeInBytes = fi.getSize();
			file = new File(filePath + fileName.substring(fileName.indexOf("\\") + 1));
			fi.write(file);
			if(fileName.endsWith(".java")){
			out.println("<a href='#id"+fileName.split("/")[1].replaceAll(" ","")+"'><button>"+fileName.split("/")[1]+"</button></a>");
			}
			fileList.add(file);
				}
			}

			//filter files for .java

			fileList = fileList.stream().filter(e -> e.getName().endsWith(".java")).collect(Collectors.toList());

			//Get all methods and store them
			//Get all VAr and store them
			Map<String, String> allGlobalVar = new LinkedHashMap();
			Map<String, MainMethod> allFileMethods = new HashMap();

			for (File nowfile : fileList) {
				List<String> allProgrammeList = new ArrayList();

				try (BufferedReader br = new BufferedReader(new FileReader(nowfile))) {

			String line;
			int no = 1;

			while ((line = br.readLine()) != null) {
				//Adding number and the coloum numbers
				if (!line.trim().equals("")) {

					allProgrammeList.add(no + "#" + line);
					no++;
				}
			}
				} catch (Exception e) {
			e.printStackTrace();
				}

				String regexString = "";

				for (int x = 0; x < allProgrammeList.size(); x++)
			regexString += allProgrammeList.get(x) + "\n";

				String className = "";

				Matcher classF = Pattern.compile("class (.*)( )*\\{").matcher(regexString);
				while (classF.find()) {
			className = classF.group(1);

				}

				currentClassName = className;
				//replace if } with +if to resolve complexity
				Pattern p = Pattern.compile("if( )*\\((.)*\\)( )*\\{(.|\\n)*?(\\d+#.*})");
				Matcher mif = p.matcher(regexString);
				while (mif.find()) {
			// replace first number with "number" and second number with the first
			String identifier = mif.group(5);
			String ifIdentify = identifier.replace("}", "-if");
			regexString = regexString.replace(identifier, ifIdentify);
				}
				// if end

				//replace for } with +for to resolve complexity
				Pattern p1 = Pattern.compile("for( )*\\((.)*\\)( )*\\{(.|\\n)*?(\\d+#.*})");
				Matcher mif1 = p1.matcher(regexString);
				while (mif1.find()) {
			// replace first number with "number" and second number with the first
			String identifier = mif1.group(5);
			String ifIdentify = identifier.replace("}", "-for");
			regexString = regexString.replace(identifier, ifIdentify);
				}
				//for  end

				Matcher m = Pattern.compile("((.+\\(.*\\))( )*\\{(\\n|\\r|\\n|.)*?\\})").matcher(regexString);
				while (m.find()) {

			//Name with the access 
			String methodName = m.group(2);

			String methodWithAccessAndReturn = (methodName.replaceAll("\\(.*\\)", ""));

			String onlyMethodName = methodWithAccessAndReturn.substring(methodWithAccessAndReturn.lastIndexOf(" "));

			MainMethod method = new MainMethod();
			String methodBody = m.group().substring(m.group().indexOf("{"));
			method.setMethodBody(methodBody);

			Pattern pattern = Pattern.compile("(\\d*)#.*" + onlyMethodName);
			Matcher matcher = pattern.matcher(methodBody);
			

			if (matcher.find()) {
				//check if method 
				method.setRecursiveCall(true);
				method.setRecursiveCallNo(matcher.group(1));
			}

			allFileMethods.put(onlyMethodName + "," + className, method);
				}
				//All methods added 

				//Sperate methods from class
				String[] removeMetho = { regexString };

				allFileMethods.entrySet().forEach(e -> {
			removeMetho[0] = removeMetho[0].replace(e.getValue().getMethodBody(), "");
				});

				Matcher globalVariables = Pattern.compile("(\\d)+#.+ (.+)=.+;").matcher(removeMetho[0]);
				while (globalVariables.find()) {

			allGlobalVar.put(globalVariables.group(1) + "," + className, globalVariables.group(2));
				}
			}
            //Checking individual file
			for (File nowfile : fileList) {
		%>
	</div>
	</br>
	</br>
	<hr>
	<h1 id="<%="id"+nowfile.getName().replaceAll(" ","")%>"><%=nowfile.getName()%></h1>
	<hr>
	<div hidden>
	<%
		List<String> list = new ArrayList();
		//Set<String> listOfOtherMethodCallsThisFile = new HashSet();
		Map<String, String> normalToNormal = new LinkedHashMap();
		Map<String, String> normalToRecursive = new LinkedHashMap();
		Map<String, String> RecursiveToNormal = new LinkedHashMap();
		Map<String, String> RecursiveToRecursive = new LinkedHashMap();
		Map<String, String> globalVar = new LinkedHashMap();

		try (BufferedReader br = new BufferedReader(new FileReader(nowfile))) {
			String line;
			int no = 1;

			while ((line = br.readLine()) != null) {
		// process the line.
		//Add Numbers and Code-line to the list 
		if (!line.trim().equals("")) {
			list.add(no + "#" + line);
			out.println(line + "</br>");
			no++;
		}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		out.println("<hr>");
		out.println("<hr>");
		out.println("<br><br>");
		out.println("<br><br>");

		String regexString = "";

		for (int x = 0; x < list.size(); x++)
			regexString += list.get(x) + "\n";

		//Finding the main class name 

		//Map designed with method name and body
		Map<String, MainMethod> thisFileMethods = new HashMap();
		Map<String, Integer> table1 = new HashMap();
		Map<String, Integer> table2 = new HashMap();
		Map<String, Integer> table3 = new HashMap();
		Map<String, Integer> table4 = new HashMap();
		Map<String, Integer> table5 = new HashMap();
		Map<String, Integer> table6 = new HashMap();

		//replace if } with +if to resolve complexity
		Pattern p = Pattern.compile("if( )*\\((.)*\\)( )*\\{(.|\\n)*?(\\d+#.*})");
		Matcher mif = p.matcher(regexString);
		while (mif.find()) {
			String identifier = mif.group(5);
			String ifIdentify = identifier.replace("}", "-if");
			regexString = regexString.replace(identifier, ifIdentify);
		}
		//replace if end

		//replace for } with +for to resolve complexity
		Pattern p1 = Pattern.compile("for( )*\\((.)*\\)( )*\\{(.|\\n)*?(\\d+#.*})");
		Matcher mif1 = p1.matcher(regexString);
		while (mif1.find()) {
			// replace first number with "number" and second number with the first
			String identifier = mif1.group(5);
			String ifIdentify = identifier.replace("}", "-for");
			regexString = regexString.replace(identifier, ifIdentify);
		}
		//replace for  end

		Matcher m = Pattern.compile("((.+\\(.*\\))( )*\\{(\\n|\\r|\\n|.)*?\\})").matcher(regexString);
		while (m.find()) {

			//Name with access and return 
			String methodName = m.group(2);

			String methodWithAccessAndReturn = (methodName.replaceAll("\\(.*\\)", ""));

			String onlyMethodName = methodWithAccessAndReturn.substring(methodWithAccessAndReturn.lastIndexOf(" "));

			MainMethod method = new MainMethod();
			String methodBody = m.group().substring(m.group().indexOf("{"));
			method.setMethodBody(methodBody);

			//Get number of the recursive call to own method
			Pattern pattern = Pattern.compile("(\\d*)#.*" + onlyMethodName);
			Matcher matcher = pattern.matcher(methodBody);
			//set recursive call no and put to method object
			if (matcher.find()) {

		//check if method recursive
		method.setRecursiveCall(true);
		// 			System.out.println("own method call found");
		method.setRecursiveCallNo(matcher.group(1));
			}
			System.out.println(thisFileMethods + "\n_________________________________________");

			thisFileMethods.put(onlyMethodName, method);
		}
	%>
</div>
	<!-- Inheritance Complexity -->
	<!-- Weight Changing -->
	<form action="AccessFilesServlet" method="post" class="form-group" style="width: 50%; margin-left: 395px;">
				<table class="table table-responsive-lg">
					<caption style="caption-side: top; text-align:center; font-size:x-large;">Weights related to the Inheritance factor</caption>
					<thead class="table-dark">
						<tr>
							<th scope="col" style="text-align:center">Program Component</th>
							<th scope="col" style="text-align:center">Weight</th>
						</tr>
					</thead>
					<tbody>
						<tr class="table-secondary">
							<td class="d-flex justify-content-center">Direct Inheritance Weight</td>
							<td><input class="form-control" type="number"
								name="inputPrimitiveReturnWeight" id="inputPrimitiveReturnWeight" value="1"></td>
						</tr>
						<tr class="table-secondary">
							<td class="d-flex justify-content-center">Indirect Inheritance Weight</td>
							<td><input class="form-control" type="number"
								name="inputCompositeReturnWeight" id="inputCompositeReturnWeight" value="2"></td>
						</tr>
					</tbody>
				</table>
				<div class="col text-right">
					<button class="btn btn-dark" type="submit" name="sumbitButton"
						id="sumbitButton" disabled>Save</button>
				</div>
			</form>
	
	<br>
	<!-- Inheritance Complexit table -->
	<table  style="width: 78%; margin-left: 184px; background-color: #fff; " class="table">
		<colgroup>
			<col style="width: 6%;">
			<col style="width: 48%;">
			<col style="width: 6%;">
			<col style="width: 6%;">
			<col style="width: 6%;">
			<col style="width: 6%;">
			<col style="width: 6%;">
			<col style="width: 6%;">
			<col style="width: 10%;">
		</colgroup>

		<h1 class="display-1"
			style="padding-left: 366px; margin-left: 100px; font-family: century gothic; font-size: 50px; margin-top: 10px">
			<font color="#00376c">Complexity of Inheritance</font>
		</h1>
		<br>
		<tbody>
			<tr>
				<th>Line No</th>
				<th>Program statements</th>
				<th>Ndi</th>                <!--  (No of direct inheritances) -->
				<th>Nidi</th>               <!-- (No of indirect inheritances) -->
				<th>Ti</th>                 <!-- Total inheritances -->
				<th>Ci</th>                 <!-- Ci -->
			</tr>
			<%!public String getMapping(String className, Map<String, String> classesAndData) {

		Matcher extendedClass = Pattern.compile(".*extends( )+(.+)").matcher(className);
		String fullClassMap = className;
		if (extendedClass.find()) {
			//	System.out.println(classesAndData.get(extendedClass.group(2).trim()).equals("")+"");

			if (classesAndData.get(extendedClass.group(2).trim()).equals("")) {
				fullClassMap = fullClassMap + "null";
			} else {
				fullClassMap += classesAndData.get(extendedClass.group(2).trim());
			}
		}
		return fullClassMap;
	}%>

			<%
				Map<String, String> classesAndData = new LinkedHashMap();

							Matcher classes = Pattern.compile("class( )+(.+)\\{").matcher(regexString);

							while (classes.find()) {
								String className = classes.group(2);
								if (className.contains("extends")) {
									classesAndData.put(className.substring(0, className.indexOf("extends")).trim(),
											className);
								} else {

									classesAndData.put(className, "");
								}
							}

							for (int i1 = 0; i1 < list.size(); i1++) {

								String originalCodeLine = list.get(i1).toString();
								String codeLine[] = { list.get(i1).toString() };
								String number = codeLine[0].substring(0, codeLine[0].indexOf("#"));

								int ci = 0;
								int classScore = 0;
								int direct = 0;
								int inDirect = 0;
								String classNameCol = "";

								Matcher matchAgain = Pattern.compile("class( )+(.+)\\{").matcher(originalCodeLine);

								while (matchAgain.find()) {
									String className = matchAgain.group(2);

									if (originalCodeLine.contains("extends")) {

										direct = 1;

										String lastExtend = className.substring(className.indexOf("extends"));
										String fullClassMap = className;
										System.out.println(
												className.split("extends")[0] + "Extendssssss");
										//split the line from extends keyword
										classNameCol = className.split("extends")[0];
										Matcher extendedClass = Pattern.compile("extends( )+(.+)").matcher(className);
										if (extendedClass.find()) {

											while (!fullClassMap.contains("null")) {

												fullClassMap = getMapping(fullClassMap, classesAndData);

											}

											Matcher countOfExtend = Pattern.compile("extends").matcher(fullClassMap);
											while (countOfExtend.find()) {
												System.out.println(fullClassMap.replaceAll("null", "")
														+ "  data Map Generated count " + countOfExtend.group());
												classScore++;
											}

										}

									} else {
										System.out.println(className + "Found");
										classNameCol = className;
										classScore = 0;
									}
								}

								if (classScore > 4) {
									classScore = 4;
									ci = 4;
								}

								for (int x = 0; x <= classScore; x++) {
									ci += x;
								}
			%>


			<tr>

				<td><%=originalCodeLine.substring(0, originalCodeLine.indexOf("#"))%></td>
				<td><%=originalCodeLine.substring(originalCodeLine.indexOf("#") + 1)%></td>
				<%
					table4.put(number, ci);
				%>


				<td><%=direct%></td>
				<td><%=classScore - direct%></td>
				<td><%=classScore%></td>
				<td><%=classScore%></td>


			</tr>
			<%
				}
			%>
		</tbody>
	</table>
	</div>
	<br>
	<br>



	<%
		}

	} catch (Exception exc) {
		exc.printStackTrace();
	}

	//file ekak naththm output eka
	} else {
		out.println("<html>");
		out.println("<body>");
		out.println("<p>No file uploaded</p>");
		out.println("</body>");
		out.println("</html>");
	}
	%>

</body>
</html>