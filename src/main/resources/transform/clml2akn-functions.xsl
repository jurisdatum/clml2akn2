<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:clml2akn="http://clml2akn.mangiafico.com/"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	exclude-result-prefixes="xs clml2akn">

<xsl:function name="clml2akn:is-hcontainer" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="name" as="xs:string" select="local-name($e)" />
	<xsl:choose>
		<xsl:when test="$name = ('Group', 'Part', 'Chapter', 'Pblock', 'PsubBlock')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('P1', 'P1group', 'P2', 'P2group', 'P3', 'P4', 'P5', 'P6')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('EUPart', 'EUTitle', 'EUChapter', 'EUSection', 'EUSubsection', 'Division')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>	

<xsl:function name="clml2akn:is-inline" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/self::Emphasis">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Strong">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Underline">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::SmallCaps">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Uppercase">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Expanded">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Abbreviation">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Acronym">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Addition">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Repeal">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Substitution">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Citation">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Span">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::FootnoteRef">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Superior">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Inferior">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Character">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Strike">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

</xsl:transform>