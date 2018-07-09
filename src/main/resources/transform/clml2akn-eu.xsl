<?xml version="1.0" encoding="utf-8"?>

<!-- v2.0, written by Jim Mangiafico, updated __ June 2018 -->

<xsl:transform version="2.0"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:clml2akn="http://clml2akn.mangiafico.com/"
	exclude-result-prefixes="xs clml2akn">


<xsl:template match="EURetained">
	<xsl:choose>
		<xsl:when test="$is-fragment">
			<portionBody>
				<xsl:if test="Body/@RestrictExtent">
					<xsl:attribute name="eId">body</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="period"><xsl:with-param name="e" select="EUBody" /></xsl:call-template>
				<xsl:apply-templates select="*" />
			</portionBody>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="EUPrelims" />
			<body>
				<xsl:if test="Body/@RestrictExtent">
					<xsl:attribute name="eId">body</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="period"><xsl:with-param name="e" select="Body" /></xsl:call-template>
				<xsl:apply-templates select="EUBody/*[not(self::CommentaryRef)]" />
				<xsl:apply-templates select="Schedules" />
			</body>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="EUPrelims">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="EUPrelims//Division">
	<tblock>
		<xsl:apply-templates />
	</tblock>
</xsl:template>

<xsl:template match="MultilineTitle">
	<preface>
		<longTitle>
			<xsl:apply-templates />
		</longTitle>
	</preface>
</xsl:template>

<xsl:template match="EUPreamble">
	<preamble>
		<xsl:apply-templates />
	</preamble>
</xsl:template>

<xsl:template match="EUPart | EUTitle | EUChapter | EUSection | EUSubsection">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="name" select="lower-case(substring(local-name(), 3))" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Division">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="name" select="'level'" />
	</xsl:call-template>
</xsl:template>

<xsl:function name="clml2akn:eu-provision-name" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/self::P1">article</xsl:when>
		<xsl:when test="$e/self::P2">paragraph</xsl:when>
	</xsl:choose>
</xsl:function>


<!--  -->

<xsl:template match="ListItem/Division[@Type='Annotation']">
	<tblock class="annotation">
		<xsl:apply-templates />
	</tblock>
</xsl:template>


<!-- signatures -->

<xsl:template match="EURetained//Signee">
	<blockContainer>
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>


<!-- inline -->

<xsl:template match="Uppercase">
	<inline name="uppercase">
		<xsl:apply-templates />
	</inline>
</xsl:template>


</xsl:transform>
