<?xml version="1.0" encoding="utf-8"?>

<!-- v2.0.4, written by Jim Mangiafico -->

<xsl:transform version="2.0"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:clml2akn="http://clml2akn.mangiafico.com/"
	exclude-result-prefixes="xs ukl ukm dc dct atom clml2akn">


<xsl:function name="clml2akn:alias" as="element()?">
	<xsl:param name="uri" as="xs:string" />
	<xsl:for-each select="('/wsi/', '/nisi/')">
		<xsl:if test="contains($uri, .)">
			<FRBRalias value="{replace($uri, ., '/uksi/')}" name="UnitedKingdomStatutoryInstrument" />
		</xsl:if>
	</xsl:for-each>
</xsl:function>


<xsl:variable name="work-date">
	<xsl:choose>
		<xsl:when test="exists(/ukl:Legislation/ukm:Metadata/ukm:PrimaryMetadata)">
			<xsl:choose>
				<xsl:when test="exists(/ukl:Legislation/ukm:Metadata/ukm:PrimaryMetadata/ukm:EnactmentDate)">
					<xsl:value-of select="/ukl:Legislation/ukm:Metadata/ukm:PrimaryMetadata/ukm:EnactmentDate/@Date" />
				</xsl:when>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="exists(/ukl:Legislation/ukm:Metadata/ukm:SecondaryMetadata)">
			<xsl:choose>
				<xsl:when test="exists(/ukl:Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:Made)">
					<xsl:value-of select="/ukl:Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:Made/@Date" />
				</xsl:when>
				<xsl:when test="exists(/ukl:Legislation/ukl:Secondary/ukl:SecondaryPrelims/ukl:MadeDate/ukl:DateText/node())">
					<xsl:value-of select="clml2akn:parse-date(/ukl:Legislation/ukl:Secondary/ukl:SecondaryPrelims/ukl:MadeDate/ukl:DateText)" />
				</xsl:when>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="exists(/ukl:Legislation/ukm:Metadata/ukm:EUMetadata/ukm:EnactmentDate)">
			<xsl:value-of select="/ukl:Legislation/ukm:Metadata/ukm:EUMetadata/ukm:EnactmentDate/@Date" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="expr-date" as="xs:string">
	<xsl:variable name="dct-valid" as="element()?" select="/ukl:Legislation/ukm:Metadata/dct:valid" />
	<xsl:choose>
		<xsl:when test="exists($dct-valid)">
			<xsl:value-of select="$dct-valid" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$work-date" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<!-- dates -->

<xsl:variable name="generation-date" as="xs:date?">
	<xsl:sequence select="/ukl:Legislation/ukm:Metadata/ukm:PrimaryMetadata/ukm:EnactmentDate/@Date" />
	<xsl:sequence select="/ukl:Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:Made/@Date" />
	<xsl:sequence select="/ukl:Legislation/ukm:Metadata/ukm:EUMetadata/ukm:EnactmentDate/@Date" />
</xsl:variable>

<xsl:variable name="revision-dates" as="xs:date*">
	<xsl:for-each select="/ukl:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion']/@title[. castable as xs:date][not(. = $generation-date)]">
		<xsl:sort select="." />
		<xsl:sequence select="." />
	</xsl:for-each>
</xsl:variable>

<xsl:variable name="lifecycle-dates" as="xs:date*" select="($generation-date, $revision-dates)" />

<xsl:function name="clml2akn:make-date-id" as="xs:string">
	<xsl:param name="date" as="xs:date" />
	<xsl:sequence select="concat('date-', translate(string($date), '-', ''))" />
</xsl:function>

<xsl:function name="clml2akn:make-time-interval-id" as="xs:string">
	<xsl:param name="start" as="xs:date?" />
	<xsl:param name="end" as="xs:date?" />
	<xsl:choose>
		<xsl:when test="exists($start) and exists($end)">
			<xsl:sequence select="concat('from-', translate(string($start), '-', ''), '-to-', translate(string($end), '-', ''))" />
		</xsl:when>
		<xsl:when test="exists($start)">
			<xsl:sequence select="concat('from-', translate(string($start), '-', ''))" />
		</xsl:when>
		<xsl:when test="exists($end)">
			<xsl:sequence select="concat('to-', translate(string($end), '-', ''))" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'time'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:template match="ukm:Metadata">

	<meta>
		<identification source="#source">

			<FRBRWork>
				<FRBRthis value="{$this-uri}" />
				<FRBRuri value="{$doc-uri}" />
				<xsl:copy-of select="clml2akn:alias($this-uri)" />
				<FRBRdate date="{$work-date}">
					<xsl:attribute name="name">
						<xsl:choose>
							<xsl:when test="ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value = 'primary'">enacted</xsl:when>
							<xsl:when test="ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value = 'secondary'">made</xsl:when>
							<xsl:when test="ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value = 'euretained'">adopted</xsl:when>
						</xsl:choose>
					</xsl:attribute>
				</FRBRdate>
				<FRBRauthor>
					<xsl:attribute name="href">
						<xsl:choose>
							<xsl:when test="starts-with($ukm-doctype, 'EuropeanUnion')">
								<xsl:value-of select="ukm:EUMetadata/ukm:CreatedBy[1]/@URI" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>http://www.legislation.gov.uk/id/</xsl:text>
								<xsl:choose>
									<xsl:when test="$ukm-doctype = 'EnglandAct'">legislature/EnglishParliament</xsl:when>
									<xsl:when test="$ukm-doctype = 'GreatBritainAct'">legislature/ParliamentOfGreatBritain</xsl:when>
									<xsl:when test="$ukm-doctype = 'IrelandAct'">legislature/OldIrishParliament</xsl:when>
									<xsl:when test="$ukm-doctype = 'NorthernIrelandAct'">legislature/NorthernIrelandAssembly</xsl:when>
									<xsl:when test="$ukm-doctype = 'NorthernIrelandAssemblyMeasure'">legislature/NorthernIrelandAssembly</xsl:when>
									<xsl:when test="$ukm-doctype = 'NorthernIrelandParliamentAct'">legislature/NorthernIrelandParliament  </xsl:when>
									<xsl:when test="$ukm-doctype = 'NorthernIrelandOrderInCouncil'">government/uk</xsl:when>
									<xsl:when test="$ukm-doctype = 'NorthernIrelandDraftOrderInCouncil'">government/uk</xsl:when>
									<xsl:when test="$ukm-doctype = 'NorthernIrelandStatutoryRule'">government/northern-ireland</xsl:when>
									<xsl:when test="$ukm-doctype = 'NorthernIrelandDraftStatutoryRule'">government/northern-ireland</xsl:when>
									<xsl:when test="$ukm-doctype = 'ScottishAct'">legislature/ScottishParliament</xsl:when>
									<xsl:when test="$ukm-doctype = 'ScottishOldAct'">legislature/OldScottishParliament</xsl:when>
									<xsl:when test="$ukm-doctype = 'ScottishStatutoryInstrument'">government/scotland</xsl:when>
									<xsl:when test="$ukm-doctype = 'ScottishDraftStatutoryInstrument'">government/scotland</xsl:when>
									<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchInstrument'">legislature/GeneralSynod</xsl:when>
									<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchMeasure'">legislature/GeneralSynod</xsl:when>
									<xsl:when test="$ukm-doctype = 'UnitedKingdomPrivateAct'">legislature/UnitedKingdomParliament</xsl:when>
									<xsl:when test="$ukm-doctype = 'UnitedKingdomPublicGeneralAct'">legislature/UnitedKingdomParliament</xsl:when>
									<xsl:when test="$ukm-doctype = 'UnitedKingdomLocalAct'">legislature/UnitedKingdomParliament</xsl:when>
									<xsl:when test="$ukm-doctype = 'UnitedKingdomMinisterialOrder'">government/uk</xsl:when>
									<xsl:when test="$ukm-doctype = 'UnitedKingdomStatutoryInstrument'">government/uk</xsl:when>
									<xsl:when test="$ukm-doctype = 'UnitedKingdomDraftStatutoryInstrument'">government/uk</xsl:when>
									<xsl:when test="$ukm-doctype = 'WelshAssemblyMeasure'">legislature/NationalAssemblyForWales</xsl:when>
									<xsl:when test="$ukm-doctype = 'WelshNationalAssemblyAct'">legislature/NationalAssemblyForWales</xsl:when>
									<xsl:when test="$ukm-doctype = 'WelshParliamentAct'">legislature/WelshParliament</xsl:when>
									<xsl:when test="$ukm-doctype = 'WelshStatutoryInstrument'">government/wales</xsl:when>
									<xsl:when test="$ukm-doctype = 'WelshDraftStatutoryInstrument'">government/wales</xsl:when>
									<xsl:when test="$ukm-doctype = 'UnitedKingdomMinisterialDirection'">government/uk</xsl:when>
									<xsl:when test="$ukm-doctype = 'UnitedKingdomStatutoryRuleOrOrder'">government/uk</xsl:when>
									<xsl:when test="$ukm-doctype = 'NorthernIrelandStatutoryRuleOrOrder'">government/northern-ireland</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</FRBRauthor>
				<FRBRcountry>
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="$ukm-doctype = 'EnglandAct'">GB-ENG</xsl:when>
							<xsl:when test="$ukm-doctype = 'GreatBritainAct'">GB-GBN</xsl:when>
							<xsl:when test="$ukm-doctype = 'IrelandAct'">IE</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandAct'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandAssemblyMeasure'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandParliamentAct'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandOrderInCouncil'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandDraftOrderInCouncil'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandStatutoryRule'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandDraftStatutoryRule'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishAct'">GB-SCT</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishOldAct'">GB-SCT</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishStatutoryInstrument'">GB-SCT</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishDraftStatutoryInstrument'">GB-SCT</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchInstrument'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchMeasure'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomPrivateAct'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomPublicGeneralAct'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomLocalAct'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomMinisterialOrder'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomStatutoryInstrument'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomDraftStatutoryInstrument'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshAssemblyMeasure'">GB-WLS</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshNationalAssemblyAct'">GB-WLS</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshParliamentAct'">GB-WLS</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshStatutoryInstrument'">GB-WLS</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshDraftStatutoryInstrument'">GB-WLS</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomMinisterialDirection'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomStatutoryRuleOrOrder'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandStatutoryRuleOrOrder'">GB-NIR</xsl:when>
							<xsl:when test="starts-with($ukm-doctype, 'EuropeanUnion')">EU</xsl:when>
							<xsl:otherwise>GB-UKM</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</FRBRcountry>
				<xsl:if test="ukm:SecondaryMetadata/ukm:DocumentClassification/ukm:DocumentMinorType">
					<FRBRsubtype value="{ukm:SecondaryMetadata/ukm:DocumentClassification/ukm:DocumentMinorType/@Value}" />
				</xsl:if>
				<FRBRnumber value="{ukm:*/ukm:Number/@Value}" />
				<FRBRname>
					<xsl:attribute name="value">
						<xsl:variable name="year" select="ukm:PrimaryMetadata/ukm:Year/@Value | ukm:SecondaryMetadata/ukm:Year/@Value | ukm:EUMetadata/ukm:Year/@Value" />
						<xsl:variable name="num" select="ukm:PrimaryMetadata/ukm:Number/@Value | ukm:SecondaryMetadata/ukm:Number/@Value | ukm:EUMetadata/ukm:Number/@Value" />
						<xsl:choose>
							<xsl:when test="$ukm-doctype = 'EnglandAct'">
								<xsl:value-of select="concat($year, ' c. ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'GreatBritainAct'">
								<xsl:value-of select="concat($year, ' c. ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'IrelandAct'">
								<xsl:value-of select="concat($year, ' c. ', $num, ' [I]')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandAct'">
								<xsl:value-of select="concat($year, ' c. ', $num, ' (N.I.)')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandAssemblyMeasure'">
								<xsl:value-of select="concat($year, ' c. ', $num, ' (N.I.)')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandParliamentAct'">
								<xsl:value-of select="concat($year, ' c. ', $num, ' (N.I.)')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandOrderInCouncil' or $ukm-doctype = 'NorthernIrelandDraftOrderInCouncil'">
								<xsl:variable name="alt-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='NI']/@Value" />
								<xsl:value-of select="concat('S.I. ', $year, '/', $num, ' (N.I. ', $alt-num, ')')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandStatutoryRule' or $ukm-doctype = 'NorthernIrelandDraftStatutoryRule'">
								<xsl:choose>
									<xsl:when test="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']">
										<xsl:variable name="c-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']/@Value" />
										<xsl:value-of select="concat('S.R. ', $year, '/', $num, ' (C. ', $c-num, ')')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('S.R. ', $year, '/', $num)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandStatutoryRuleOrOrder'">
								<xsl:choose>
									<xsl:when test="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']">
										<xsl:variable name="c-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']/@Value" />
										<xsl:value-of select="concat('S.R. &amp; O. (N.I.) ', $year, '/', $num, ' (C. ', $c-num, ')')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('S.R. &amp; O. (N.I.) ', $year, '/', $num)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishAct'">
								<xsl:value-of select="concat($year, ' asp ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishOldAct'">
								<xsl:value-of select="concat($year, ' c. ', $num, ' [S]')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishStatutoryInstrument' or $ukm-doctype = 'ScottishDraftStatutoryInstrument'">
								<xsl:choose>
									<xsl:when test="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']">
										<xsl:variable name="c-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']/@Value" />
										<xsl:value-of select="concat('S.S.I. ', $year, '/', $num, ' (C. ', $c-num, ')')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('S.S.I. ', $year, '/', $num)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchInstrument'">
								<xsl:value-of select="concat('Church Instrument ', $year, '/', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchMeasure'">
								<xsl:value-of select="concat($year, ' No. ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomPrivateAct'">
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomPublicGeneralAct'">
								<xsl:value-of select="concat($year, ' c. ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomLocalAct'">
								<xsl:value-of select="$year" />
								<xsl:text> c. </xsl:text>
								<xsl:number value="$num" format="i" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomMinisterialOrder'">
								<xsl:value-of select="concat('Ministerial Order ', $year, '/', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomMinisterialDirection'">
								<xsl:value-of select="concat('Ministerial Direction ', $year, '/', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomStatutoryInstrument' or $ukm-doctype = 'UnitedKingdomDraftStatutoryInstrument'">
								<xsl:value-of select="concat('S.I. ', $year, '/', $num)" />
								<xsl:for-each select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C' or @Category='L' or @Category='S']">
									<xsl:value-of select="concat(' (', @Category,'. ', @Value, ')')" />
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomStatutoryRuleOrOrder'">
								<xsl:value-of select="concat('S.R. &amp; O. ', $year, '/', $num)" />
								<xsl:for-each select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C' or @Category='L' or @Category='S']">
									<xsl:value-of select="concat(' (', @Category,'. ', @Value, ')')" />
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshAssemblyMeasure'">
								<xsl:value-of select="concat($year, ' nawm ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshNationalAssemblyAct'">
								<xsl:value-of select="concat($year, ' anaw ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshParliamentAct'">
								<xsl:value-of select="concat($year, ' asc ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshStatutoryInstrument' or $ukm-doctype = 'WelshDraftStatutoryInstrument'">
								<xsl:variable name="alt-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='W' or @Category='Cy']/@Value" />
								<xsl:choose>
									<xsl:when test="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']">
										<xsl:variable name="c-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']/@Value" />
										<xsl:value-of select="concat('S.I. ', $year, '/', $num, ' (W. ', $alt-num, ') (C. ', $c-num,')')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('S.I. ', $year, '/', $num, ' (W. ', $alt-num, ')')" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'EuropeanUnionRegulation'">
								<xsl:value-of select="concat('Regulation (EU) ', $year, '/', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'EuropeanUnionDecision'">
								<xsl:value-of select="concat('Decision (EU) ', $year, '/', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'EuropeanUnionDirective'">
								<xsl:value-of select="concat('Directive (EU) ', $year, '/', $num)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($year, ' c. ', $num)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</FRBRname>
				<FRBRprescriptive value="true" />
			</FRBRWork>

			<FRBRExpression>
				<FRBRthis value="{$expr-this}" />
				<FRBRuri value="{$expr-uri}" />
				<xsl:copy-of select="clml2akn:alias($expr-this)" />
				<FRBRdate date="{$expr-date}">
					<xsl:attribute name="name">
						<xsl:choose>
							<xsl:when test="dct:valid">validFrom</xsl:when>
							<xsl:when test="ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value = 'primary'">enacted</xsl:when>
							<xsl:when test="ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value = 'secondary'">made</xsl:when>
							<xsl:when test="ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value = 'euretained'">adopted</xsl:when>
						</xsl:choose>
					</xsl:attribute>
				</FRBRdate>
				<FRBRauthor href="#source" />
				<FRBRlanguage>
					<xsl:attribute name="language">
						<xsl:choose>
							<xsl:when test="dc:language = 'cy'">cym</xsl:when>
							<xsl:otherwise>eng</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</FRBRlanguage>
			</FRBRExpression>

			<FRBRManifestation>
				<xsl:variable name="mani-this" select="concat($expr-this, '/data.akn')" />
				<FRBRthis value="{$mani-this}" />
				<FRBRuri value="{$expr-uri}/data.akn" />
				<xsl:copy-of select="clml2akn:alias($mani-this)" />
				<FRBRdate date="{current-date()}" name="transform" />
				<FRBRauthor href="http://www.legislation.gov.uk" />
				<FRBRformat value="application/akn+xml" />
			</FRBRManifestation>
		</identification>
		
		<!-- classification -->
		<xsl:if test="dc:subject">
			<classification source="#source">
				<xsl:for-each select="dc:subject">
					<keyword value="{lower-case(.)}" showAs="{.}" dictionary="http://www.legislation.gov.uk" />
				</xsl:for-each>
			</classification>
		</xsl:if>
				
		<!-- lifecycle -->
		<lifecycle source="#source">
			<xsl:if test="exists($generation-date)">
		        <eventRef eId="{ clml2akn:make-date-id($generation-date) }" date="{ $generation-date }" type="generation" source="#source" />
			</xsl:if>
			<xsl:for-each select="$revision-dates">
		        <eventRef eId="{ clml2akn:make-date-id(.) }" date="{ . }" type="amendment" source="#source" />
			</xsl:for-each>
		</lifecycle>
		
		<!-- analysis -->
		<!-- adds a passiveModification for each Addition, Repeal or Substitution (only one per unique ChangeId attribute) -->
		<!-- adds a restriction for each unique RestrictExtent attribute -->
		<xsl:variable name="modifications" select="//Addition | //Repeal | //Substitution" as="element()*" />
		<xsl:variable name="restrictions" select="//*[@RestrictExtent]" as="element()*" />
		<xsl:if test="$modifications or $restrictions">
			<analysis source="#source">
				<xsl:if test="$modifications">
					<passiveModifications>
						<xsl:for-each-group select="$modifications" group-by="@ChangeId">
							<textualMod>
								<xsl:attribute name="type">
									<xsl:choose>
										<xsl:when test="self::Addition">insertion</xsl:when>
										<xsl:when test="self::Repeal">repeal</xsl:when>
										<xsl:when test="self::Substitution">substitution</xsl:when>
									</xsl:choose>
								</xsl:attribute>
								<xsl:attribute name="eId">
									<xsl:text>mod-</xsl:text>
									<xsl:value-of select="@ChangeId" />
								</xsl:attribute>
								<source href="#{@CommentaryRef}" />
								<destination href="#{./ancestor::*[@id][1]/@id}" /><!-- id of first ancestor -->
							</textualMod>
						</xsl:for-each-group>
					</passiveModifications>
				</xsl:if>
				<xsl:if test="$restrictions">
					<restrictions source="#source">
						<xsl:for-each select="$restrictions">
							<xsl:sort select="@id" />
							<restriction>
								<xsl:if test="not(self::Legislation)">
									<xsl:attribute name="href">
										<xsl:text>#</xsl:text>
										<xsl:choose>
											<xsl:when test="self::ContentsItem"><xsl:value-of select="@ContentRef" /></xsl:when>
											<xsl:when test="self::PrimaryPrelims">preface</xsl:when>
											<xsl:when test="self::Body">body</xsl:when>
											<xsl:when test="self::P1group[count(P1) = 1][not(P1/@RestrictExtent)]"><xsl:value-of select="clml2akn:vid(P1)" /></xsl:when>
											<xsl:when test="self::P2group[count(P2) = 1]"><xsl:value-of select="clml2akn:vid(P2)" /></xsl:when>
											<xsl:otherwise><xsl:value-of select="clml2akn:vid(.)" /></xsl:otherwise>
										</xsl:choose>
										<xsl:if test="count(key('id', @id)[@RestrictExtent][not(ancestor::Versions)]) > 1">
											<xsl:text>[</xsl:text>
											<xsl:value-of select="index-of(key('id', @id), .)" />
											<xsl:text>]</xsl:text>
										</xsl:if>
									</xsl:attribute>
								</xsl:if>
								<xsl:attribute name="refersTo">
									<xsl:text>#</xsl:text>
									<xsl:value-of select="lower-case(replace(@RestrictExtent,'\.',''))" />
								</xsl:attribute>
								<xsl:attribute name="type">jurisdiction</xsl:attribute>
							</restriction>
						</xsl:for-each>
					</restrictions>
				</xsl:if>
			</analysis>
		</xsl:if>
		
		<!-- temporal data -->
		<!-- add a timeInterval element for each unique pair of dates -->
		<xsl:if test="exists($lifecycle-dates)">
			<temporalData source="#source">
				<temporalGroup eId="all-consecutive-intervals">
					<xsl:for-each select="$lifecycle-dates">
						<xsl:variable name="start" as="xs:date" select="." />
						<xsl:variable name="end" as="xs:date?" select="subsequence($lifecycle-dates, position() + 1, 1)" />
							<timeInterval eId="{ clml2akn:make-time-interval-id($start, $end) }">
								<xsl:attribute name="start">
									<xsl:text>#date-</xsl:text>
									<xsl:value-of select="translate(string($start), '-', '')" />
								</xsl:attribute>
								<xsl:if test="exists($end)">
									<xsl:attribute name="end">
										<xsl:text>#date-</xsl:text>
										<xsl:value-of select="translate(string($end), '-', '')" />
									</xsl:attribute>
								</xsl:if>
								<xsl:attribute name="refersTo">
									<xsl:text>#in-force</xsl:text>
								</xsl:attribute>
							</timeInterval>
					</xsl:for-each>
				</temporalGroup>
				<temporalGroup eId="all-possible-intervals">
					<xsl:for-each select="$lifecycle-dates">
						<xsl:variable name="start" as="xs:date" select="." />
						<xsl:variable name="i" as="xs:integer" select="position()" />
						<xsl:for-each select="$lifecycle-dates[position() gt $i + 1]">
							<xsl:variable name="end" as="xs:date" select="." />
							<timeInterval eId="{ clml2akn:make-time-interval-id($start, $end) }">
								<xsl:attribute name="start">
									<xsl:text>#date-</xsl:text>
									<xsl:value-of select="translate(string($start), '-', '')" />
								</xsl:attribute>
								<xsl:if test="exists($end)">
									<xsl:attribute name="end">
										<xsl:text>#date-</xsl:text>
										<xsl:value-of select="translate(string($end), '-', '')" />
									</xsl:attribute>
								</xsl:if>
								<xsl:attribute name="refersTo">
									<xsl:text>#in-force</xsl:text>
								</xsl:attribute>
							</timeInterval>
						</xsl:for-each>
						<xsl:if test="$i lt last()">
							<timeInterval eId="{ clml2akn:make-time-interval-id($start, ()) }">
								<xsl:attribute name="start">
									<xsl:text>#date-</xsl:text>
									<xsl:value-of select="translate(string($start), '-', '')" />
								</xsl:attribute>
								<xsl:attribute name="refersTo">
									<xsl:text>#in-force</xsl:text>
								</xsl:attribute>
							</timeInterval>
						</xsl:if>
					</xsl:for-each>
				</temporalGroup>
				<temporalGroup eId="referenced-intervals">
					<xsl:for-each-group select="//*[@RestrictStartDate | @RestrictEndDate]" group-by="concat(@RestrictStartDate, '-', @RestrictEndDate)">
						<xsl:sort select="concat(@RestrictStartDate, '-', @RestrictEndDate)" />
						<timeInterval>
							<xsl:if test="@RestrictStartDate">
								<xsl:attribute name="start">
									<xsl:text>#date-</xsl:text>
									<xsl:value-of select="translate(string(@RestrictStartDate), '-', '')" />
								</xsl:attribute>
							</xsl:if>
							<xsl:if test="@RestrictEndDate">
								<xsl:attribute name="end">
									<xsl:text>#date-</xsl:text>
									<xsl:value-of select="translate(string(@RestrictEndDate), '-', '')" />
								</xsl:attribute>
							</xsl:if>
							<xsl:attribute name="refersTo">	<!-- The refers attribute is a reference to a temporal concept belonging to the Akoma Ntoso ontology and specified in the references section -->
								<xsl:text>#in-force</xsl:text>
							</xsl:attribute>
						</timeInterval>
					</xsl:for-each-group>
				</temporalGroup>
			</temporalData>
		</xsl:if>

		<!-- references -->
		<!-- a passiveRef element for each UnappliedEffect -->
		<!-- a TLCOrganization for each Department -->
		<!-- a TLCLocation for each unique RestrictExtent and each AddressLine -->
		<!-- a TLCRole for each JobTitle -->
		<!-- a TLCPerson for each PersonName -->
		<!-- a TLCTerm for each unique Term -->
		<!-- a TLCConcept for each unique territorial extent and each unique Subject -->
		<references source="#source">
		
			<TLCOrganization eId="source">
				<xsl:variable name="dc-publishers" select="dc:publisher" as="xs:string*" />
				<xsl:attribute name="href">
					<xsl:text>http://www.legislation.gov.uk/id/</xsl:text>
					<xsl:choose>
						<xsl:when test="$dc-publishers = ('King''s Printer of Acts of Parliament', 'Queen''s Printer of Acts of Parliament')">
							<xsl:text>publisher/KingsOrQueensPrinterOfActsOfParliament</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('King''s Printer for Scotland', 'Queen''s Printer for Scotland')">
							<xsl:text>publisher/KingsOrQueensPrinterForScotland</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Government Printer for Northern Ireland')">
							<xsl:text>publisher/GovernmentPrinterForNorthernIreland</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('The National Archives')">
							<xsl:text>publisher/TheNationalArchives</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Statute Law Database')">
							<xsl:text>publisher/StatuteLawDatabase</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Westlaw')">
							<xsl:text>contributor/Westlaw</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="translate($dc-publishers[1], ' ', '')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="showAs">
					<xsl:choose>
						<xsl:when test="$dc-publishers = ('King''s Printer of Acts of Parliament')">
							<xsl:text>King's Printer of Acts of Parliament</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Queen''s Printer of Acts of Parliament')">
							<xsl:text>Queen's Printer of Acts of Parliament</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('King''s Printer for Scotland')">
							<xsl:text>King's Printer for Scotland</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Queen''s Printer for Scotland')">
							<xsl:text>Queen's Printer for Scotland</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Government Printer for Northern Ireland')">
							<xsl:text>Government Printer for Northern Ireland</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('The National Archives')">
							<xsl:text>The National Archives</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Statute Law Database')">
							<xsl:text>Statute Law Database</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Westlaw')">
							<xsl:text>Westlaw</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$dc-publishers[1]" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</TLCOrganization>
		
			<xsl:for-each-group select="ukm:*/ukm:UnappliedEffects/ukm:UnappliedEffect" group-by="@AffectingURI">
				<xsl:sort select="@AffectingURI" />
				<passiveRef href="{@AffectingURI}" showAs="{ukm:AffectingTitle[1]}" />
			</xsl:for-each-group>

			<xsl:for-each select="//Department">
				<TLCOrganization eId="ref-{clml2akn:id(.)}" href="/ontology/organization/uk.{replace(.,' ’','')}" showAs="{.}" />			
			</xsl:for-each>

			<xsl:for-each-group select="//@RestrictExtent" group-by="translate(., '.', '')">
				<TLCLocation eId="{lower-case(replace(.,'\.',''))}">
					<xsl:variable name="extent" select="replace(.,'E','England')" />
					<xsl:variable name="extent" select="replace($extent, 'W', 'Wales')" />
					<xsl:variable name="extent" select="replace($extent, 'S', 'Scotland')" />
					<xsl:variable name="extent" select="replace($extent, 'N.I.', 'Northern Ireland')" />
					<xsl:variable name="extent" select="replace($extent, 'NI', 'Northern Ireland')" />
					<xsl:attribute name="href">
						<xsl:text>/ontology/jurisdictions/uk.</xsl:text>
						<xsl:value-of select="translate($extent, '\+ ', '')" />
					</xsl:attribute>
					<xsl:attribute name="showAs">
						<xsl:value-of select="string-join(tokenize($extent, '\+'), ', ')" />
					</xsl:attribute>
				</TLCLocation>
			</xsl:for-each-group>
			
			<xsl:for-each select="//AddressLine">
				<xsl:variable name="normalized" as="xs:string" select="normalize-space(.)" />
				<xsl:variable name="no-commas" as="xs:string" select="translate($normalized, ' ,', '')" />
				<TLCLocation eId="{ lower-case($no-commas) }" href="/ontology/location/uk.{ $no-commas }" showAs="{ $normalized }" />
			</xsl:for-each>

			<xsl:for-each select="//JobTitle">
				<TLCRole eId="ref-{clml2akn:id(.)}" href="/ontology/role/uk.{replace(.,' ’','')}" showAs="{.}" />			
			</xsl:for-each>

			<xsl:for-each select="//PersonName">
				<TLCPerson eId="ref-{clml2akn:id(.)}" href="/ontology/persons/uk.{replace(.,' ','')}" showAs="{.}" />			
			</xsl:for-each>

 			<xsl:for-each-group select="//Term" group-by="clml2akn:term-id(.)">
 				<xsl:variable name="id" select="clml2akn:term-id(.)" />
				<TLCTerm eId="{$id}" href="/ontology/term/uk.{replace($id, 'term-', '')}" showAs="{.}" />
			</xsl:for-each-group>

			<TLCConcept eId="in-force" href="/ontology/concept/inForce" showAs="In Force" />

<!-- 			<xsl:for-each-group select="//*[@RestrictStartDate | @RestrictEndDate]" group-by="concat(@RestrictStartDate,@RestrictEndDate)">
				<xsl:sort select="concat(@RestrictStartDate,@RestrictEndDate)" />
				<TLCConcept eId="period-concept{position()}">
					<xsl:attribute name="href">
						<xsl:text>/ontology/time/</xsl:text>
						<xsl:value-of select="replace(@RestrictStartDate,'-','.')" />
						<xsl:if test="@RestrictEndDate">
							<xsl:text>-</xsl:text>
							<xsl:value-of select="replace(@RestrictEndDate,'-','.')" />
						</xsl:if>
					</xsl:attribute>
					<xsl:variable name="period-string">
						<xsl:choose>
							<xsl:when test="@RestrictStartDate and @RestrictEndDate">
								<xsl:text>from </xsl:text>
								<xsl:value-of select="@RestrictStartDate" />
								<xsl:text> until </xsl:text>
								<xsl:value-of select="@RestrictEndDate" />
							</xsl:when>
							<xsl:when test="@RestrictStartDate and not(@RestrictEndDate)">
								<xsl:text>since </xsl:text>
								<xsl:value-of select="@RestrictStartDate" />
							</xsl:when>
							<xsl:when test="not(@RestrictStartDate) and @RestrictEndDate">
								<xsl:text> before </xsl:text>
								<xsl:value-of select="@RestrictEndDate" />
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:attribute name="showAs"><xsl:value-of select="$period-string" /></xsl:attribute>
				</TLCConcept>
			</xsl:for-each-group> -->
			<xsl:for-each select="/Legislation/Secondary/SecondaryPrelims/SubjectInformation/Subject/Title |
				/Legislation/Secondary/SecondaryPrelims/SubjectInformation/Subject/Subtitle">
				<TLCConcept href="/uk/subject/{lower-case(translate(., ' ,', '-'))}" showAs="{.}" eId="{clml2akn:id(.)}" />
			</xsl:for-each>
		</references>
		
		<!-- notes -->
		<!-- see templates for Commentaries, MarginNotes & Footnotes -->
		<xsl:if test="/Legislation/Commentaries/Commentary | /Legislation/MarginNotes/MarginNote | /Legislation/Footnotes/Footnote">
			<notes source="#source">
				<xsl:apply-templates select="/Legislation/Commentaries/Commentary | /Legislation/MarginNotes/MarginNote | /Legislation/Footnotes/Footnote" />
			</notes>
		</xsl:if>
		
		<!-- proprietary -->
		<!-- all ukm:Metadata with namespace -->
		<proprietary source="#source">
			<xsl:namespace name="ukl" select="'http://www.legislation.gov.uk/namespaces/legislation'"/>
			<xsl:namespace name="ukm" select="'http://www.legislation.gov.uk/namespaces/metadata'"/>
			<xsl:namespace name="dc" select="'http://purl.org/dc/elements/1.1/'"/>
			<xsl:namespace name="dct" select="'http://purl.org/dc/terms/'"/>
			<xsl:namespace name="atom" select="'http://www.w3.org/2005/Atom'"/>
			<xsl:if test="../@RestrictStartDate">
				<ukl:RestrictStartDate value="{../@RestrictStartDate}" />
			</xsl:if>
			<xsl:if test="../@RestrictEndDate">
				<ukl:RestrictEndDate value="{../@RestrictEndDate}" />
			</xsl:if>
			<xsl:if test="../@Status">
				<ukl:Status value="{../@Status}" />
			</xsl:if>
			<xsl:apply-templates />
		</proprietary>
	</meta>

</xsl:template>

<xsl:template match="/Legislation/ukm:Metadata//*">
	<xsl:copy>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</xsl:copy>
</xsl:template>


<!-- attachments -->

<xsl:template name="attachment-metadata">
	<meta>
		<identification source="#source">
			<FRBRWork>
				<FRBRthis value=""/>
				<FRBRuri value=""/>
				<FRBRdate date="{ $work-date }" name=""/>
				<FRBRauthor href=""/>
				<FRBRcountry value="EU"/>
			</FRBRWork>
			<FRBRExpression>
				<FRBRthis value=""/>
				<FRBRuri value=""/>
				<FRBRdate date="{ $expr-date }" name=""/>
				<FRBRauthor href="#source"/>
				<FRBRlanguage language="eng"/>
			</FRBRExpression>
			<FRBRManifestation>
				<FRBRthis value=""/>
				<FRBRuri value=""/>
				<FRBRdate date="{ current-date() }" name="transform"/>
				<FRBRauthor href="http://www.legislation.gov.uk"/>
				<FRBRformat value="application/akn+xml"/>
			</FRBRManifestation>
		</identification>
	</meta>
</xsl:template>

</xsl:transform>
