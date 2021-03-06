package ${seleniumBuilderContext.getTestSuitePackageName(testSuiteName)};

import com.liferay.portalweb.portal.BaseTestSuite;
import com.liferay.portalweb.portal.NamedTestSuite;
import com.liferay.portalweb.portal.StopSeleniumTest;
import com.liferay.portalweb.portal.util.SeleniumUtil;
import com.liferay.portalweb.portal.util.liferayselenium.LiferaySelenium;

<#assign rootElement = seleniumBuilderContext.getTestSuiteRootElement(testSuiteName)>

<#assign executeElements = rootElement.elements("execute")>

<#list executeElements as executeElement>
	<#if executeElement.attributeValue("test-case")??>
		<#assign testCaseName = executeElement.attributeValue("test-case")>

		<#assign testCaseClassName = seleniumBuilderContext.getTestCaseClassName(testCaseName)>

		import ${testCaseClassName};
	<#elseif executeElement.attributeValue("test-case-command")??>
		<#assign testCaseCommand = executeElement.attributeValue("test-case-command")>

		<#assign x = testCaseCommand?last_index_of("#")>

		<#assign testCaseName = testCaseCommand?substring(0, x)>

		<#assign testCaseClassName = seleniumBuilderContext.getTestCaseClassName(testCaseName)>

		import ${testCaseClassName};
	<#elseif executeElement.attributeValue("test-class")??>
		import ${executeElement.attributeValue("test-class")};
	<#elseif executeElement.attributeValue("test-suite")??>
		<#assign importTestSuiteName = executeElement.attributeValue("test-suite")>

		<#assign importTestSuiteClassName = seleniumBuilderContext.getTestSuiteClassName(importTestSuiteName)>

		import ${importTestSuiteClassName};
	</#if>
</#list>

import junit.framework.TestSuite;

public class ${seleniumBuilderContext.getTestSuiteSimpleClassName(testSuiteName)} extends BaseTestSuite {

	public static TestSuite suite() {
		TestSuite testSuite = new NamedTestSuite();

		<#assign childElementAttributeValues = seleniumBuilderFileUtil.getChildElementAttributeValues(rootElement, "test-case-command")>

		<#list childElementAttributeValues as childElementAttributeValue>
			<#assign testCaseClassName = seleniumBuilderContext.getTestCaseSimpleClassName(childElementAttributeValue)>

			${testCaseClassName} ${seleniumBuilderFileUtil.getVariableName(testCaseClassName)};
		</#list>

		<#list executeElements as executeElement>
			<#if executeElement.attributeValue("test-case")??>
				<#assign testCaseName = executeElement.attributeValue("test-case")>

				<#assign testCaseSimpleClassName = seleniumBuilderContext.getTestCaseSimpleClassName(testCaseName)>

				testSuite.addTestSuite(${testCaseSimpleClassName}.class);
			<#elseif executeElement.attributeValue("test-class")??>
				<#assign importTestSuiteName = executeElement.attributeValue("test-class")>

				<#assign importTestSuiteSimpleClassName = seleniumBuilderFileUtil.getClassSimpleClassName(importTestSuiteName)>

				testSuite.addTest(${importTestSuiteSimpleClassName}.suite());
			<#elseif executeElement.attributeValue("test-case-command")??>
				<#assign testCaseCommand = executeElement.attributeValue("test-case-command")>

				<#assign x = testCaseCommand?last_index_of("#")>

				<#assign testCaseName = testCaseCommand?substring(0, x)>

				<#assign testCaseSimpleClassName = seleniumBuilderContext.getTestCaseSimpleClassName(testCaseName)>

				${seleniumBuilderFileUtil.getVariableName(testCaseSimpleClassName)} = new ${testCaseSimpleClassName}();

				${seleniumBuilderFileUtil.getVariableName(testCaseSimpleClassName)}.setName("test${testCaseCommand?substring(x + 1)}");

				testSuite.addTest(${seleniumBuilderFileUtil.getVariableName(testCaseSimpleClassName)});
			<#elseif executeElement.attributeValue("test-suite")??>
				<#assign importTestSuiteName = executeElement.attributeValue("test-suite")>

				<#assign importTestSuiteSimpleClassName = seleniumBuilderContext.getTestSuiteSimpleClassName(importTestSuiteName)>

				testSuite.addTest(${importTestSuiteSimpleClassName}.suite());
			</#if>
		</#list>

		LiferaySelenium liferaySelenium = SeleniumUtil.getSelenium();

		String primaryTestSuiteName = liferaySelenium.getPrimaryTestSuiteName();

		if (primaryTestSuiteName.equals("${seleniumBuilderContext.getTestSuiteClassName(testSuiteName)}")) {
			testSuite.addTestSuite(StopSeleniumTest.class);
		}

		return testSuite;
	}

}