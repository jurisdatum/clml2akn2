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
	<xsl:apply-templates>
		<xsl:with-param name="context" select="'block'" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="EUPrelims/MultilineTitle">
	<preface>
		<longTitle>
			<xsl:apply-templates />
		</longTitle>
	</preface>
</xsl:template>
<xsl:template match="MultilineTitle">
	<longTitle>
		<xsl:apply-templates />
	</longTitle>
</xsl:template>

<xsl:template match="EUPreamble">
	<preamble>
		<xsl:apply-templates />
	</preamble>
</xsl:template>

<xsl:template match="EUPreamble/CommentaryRef[following-sibling::*[1][self::P][Text]]">
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$force">
			<xsl:next-match />
		</xsl:when>
		<xsl:otherwise />
	</xsl:choose>
</xsl:template>
<xsl:template match="EUPreamble/P[preceding-sibling::*[1][self::CommentaryRef]]/Text">
	<p>
		<xsl:apply-templates select="parent::P/preceding-sibling::*[1]">
			<xsl:with-param name="force" select="true()" />
		</xsl:apply-templates>
		<xsl:apply-templates />
	</p>
</xsl:template>


<!-- structure -->

<xsl:template match="EUPart | EUTitle | EUChapter | EUSection | EUSubsection">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="name" select="lower-case(substring(local-name(), 3))" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Division">
	<xsl:param name="context" as="xs:string?" select="()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$context = 'block'">
			<tblock>
				<xsl:if test="@Type">
					<xsl:attribute name="class">
						<xsl:value-of select="lower-case(@Type)" />
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates />
				<xsl:if test="empty(*[not(self::Number or self::Title)])">
					<p/>
				</xsl:if>
			</tblock>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="hierarchy">
				<xsl:with-param name="name" select="'level'" />
				<xsl:with-param name="attrs" as="attribute()*">
					<xsl:if test="@Type">
						<xsl:attribute name="class">
							<xsl:value-of select="@Type" />
						</xsl:attribute>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:function name="clml2akn:eu-provision-name" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/self::P1">article</xsl:when>
		<xsl:when test="$e/self::P2">paragraph</xsl:when>
	</xsl:choose>
</xsl:function>


<!-- signatures -->

<xsl:template match="EURetained//Signee">
	<blockContainer>
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>


<!-- new inline -->

<xsl:template match="Uppercase">
	<inline name="uppercase"><xsl:apply-templates /></inline>
</xsl:template>
<xsl:template match="Expanded">
	<inline name="expanded"><xsl:apply-templates /></inline>
</xsl:template>


</xsl:transform>
