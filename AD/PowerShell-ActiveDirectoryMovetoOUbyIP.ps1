################################################################################
# PowerShell routine to move Windows 7 Computers into OU structure based on IP #
################################################################################

# Requires Active Directory 2008 R2 and the PowerShell ActiveDirectory module

#####################
# Environment Setup #
#####################

#Add the Active Directory PowerShell module
Import-Module ActiveDirectory

#Set the threshold for an "old" computer which will be moved to the Disabled OU
$old = (Get-Date).AddDays(-60) # Modify the -60 to match your threshold 

#Set the threshold for an "very old" computer which will be deleted
$veryold = (Get-Date).AddDays(-90) # Modify the -90 to match your threshold 


##############################
# Set the Location IP ranges #
##############################

$PreOwnedStellenbosch="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:143)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.143.0/24
$SuzukiPlumstead="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:144)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.144.0/24
$ToyotaTableview="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:211)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.211.0/24
$ToyotaN1CityStockyard="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:221)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.221.0/24
$BurchmoresCarAuctionsCape="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:226)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.226.0/24
$ForsdicksARCCape="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:231)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.231.0/24
$VWParrow="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:239)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.239.0/24
$LandRoverN1City="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:240)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.240.0/24
$ValueCentreParrow="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:244)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.244.0/24
$ToyotaAutomarkN1City="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:245)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.245.0/24
$ToyotaN1City="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:245)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.245.0/24
$ToyotaPartsWarehouseParrow="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:248)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.248.0/24
$ToyotaPaarl="\b(?:(?:10)\.)" + "\b(?:(?:128)\.)" + "\b(?:(?:250)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.128.250.0/24
$Kingsmead="\b(?:(?:10)\.)" + "\b(?:(?:131)\.)" + "\b(?:(?:131)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.131.131.0/24
$ToyotaKingsmead="\b(?:(?:10)\.)" + "\b(?:(?:131)\.)" + "\b(?:(?:131)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.131.131.0/24
$ToyotaHinoPMB="\b(?:(?:10)\.)" + "\b(?:(?:131)\.)" + "\b(?:(?:51)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.131.51.0/24
$McCarthyPreOwnedWonderboom="\b(?:(?:10)\.)" + "\b(?:(?:4)\.)" + "\b(?:(?:217)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.4.217.0/24
$VWAudiWonderboom="\b(?:(?:10)\.)" + "\b(?:(?:4)\.)" + "\b(?:(?:217)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.4.217.0/24
$ToyotaEmpangeni="\b(?:(?:10)\.)" + "\b(?:(?:41)\.)" + "\b(?:(?:1)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.41.1.0/24
$InyangaMotorsVryheid="\b(?:(?:10)\.)" + "\b(?:(?:41)\.)" + "\b(?:(?:246)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.41.246.0/24
$InyangaMotorsEmpangeni="\b(?:(?:10)\.)" + "\b(?:(?:41)\.)" + "\b(?:(?:247)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.41.247.0/24
$ValueCentreBloemfontein="\b(?:(?:10)\.)" + "\b(?:(?:42)\.)" + "\b(?:(?:239)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.42.239.0/24
$SuzukiBloemfontein="\b(?:(?:10)\.)" + "\b(?:(?:42)\.)" + "\b(?:(?:253)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.42.253.0/24
$MotorCityPMB="\b(?:(?:10)\.)" + "\b(?:(?:43)\.)" + "\b(?:(?:250)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.43.250.0/24
$ToyotaPMB="\b(?:(?:10)\.)" + "\b(?:(?:43)\.)" + "\b(?:(?:250)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.43.250.0/24
$McCarthyInsuranceServices="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:138)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.138.0/24
$ToyotaPMBAutomark="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:140)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.140.0/24
$TechnicalTrainingPinetown="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:144)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.144.0/24
$TrainingDerbyDowns="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:144)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.144.0/24
$AudiUmhlanga="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:148)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.148.0/24
$AudiCenterDurban="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:179)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.179.0/24
$LandRoverDurban="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:180)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.180.0/24
$VWUmhlanga="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:185)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.185.0/24
$BurchmoresDurbanUmgeni="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:188)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.188.0/24
$ToyotaPinetown="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:230)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.230.0/24
$VWDurban="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:231)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.231.0/24
$AutomarkGreyville="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:232)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.232.0/24
$HeadOfficeDurban="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:233)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.233.0/24
$McCarthySupportServicesDBN="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:233)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.233.0/24
$NissanGateway="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:234)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.234.0/24
$AutomarkMobeni="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:236)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.236.0/24
$ToyotaMobeni="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:236)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.236.0/24
$ToyotaTrucksWestmead="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:238)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.238.0/24
$AutomarkDurbanNorth="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:239)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.239.0/24
$ToyotaDurbanNorth="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:239)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.239.0/24
$ToyotaGreyville="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:239)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.239.0/24
$AutomarkBalito="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:241)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.241.0/24
$ToyotaBallito="\b(?:(?:10)\.)" + "\b(?:(?:46)\.)" + "\b(?:(?:241)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.46.241.0/24
$McCarthyAutoBodyRepairCentre="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:131)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.131.0/24
$McCarthyKiaKimberley="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:132)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.132.0/24
$McCarthyFoton="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:144)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.144.0/24
$McCarthyFordAndMazdaTheGlen="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:146)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.146.0/24
$McCarthyPreOwnedEdenvale="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:156)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.156.0/24
$ToyotaMidrand="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:167)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.167.0/24
$SuzukiMidrand="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:173)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.173.0/24
$MitsubishiMidrand="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:175)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.175.0/24
$McCarthyCommercialVehiclesAlberton="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:176)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.176.0/24
$VWConstantia="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:180)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.180.0/24
$NissanPreOwnedRandburg="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:204)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.204.0/24
$NissanRandburg="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:204)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.204.0/24
$NissanJHBCity="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:205)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.205.0/24
$VWSilveroaks="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:210)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.210.0/24
$NissanMounties="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:216)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.216.0/24
$NissanGermiston="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:218)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.218.0/24
$McCarthySupportServicesJHB="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:220)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.220.0/24
$VWRoodepoort="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:221)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.221.0/24
$BurchmoresSandton="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:226)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.226.0/24
$McCarthyCommercialVehiclesBoksburg="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:227)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.227.0/24
$ToyotaWoodmead="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:234)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.234.0/24
$TechnicalTrainingMidrand="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:235)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.235.0/24
$ToyotaEdenvale="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:238)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.238.0/24
$LandRoverConstantiaKloof="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:239)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.239.0/24
$LandRoverMidrand="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:249)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.249.0/24
$ToyotaBruma="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:251)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.251.0/24
$ToyotaHinoSelby="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:252)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.252.0/24
$McCarthyCommercialVehiclesKlipstone="\b(?:(?:10)\.)" + "\b(?:(?:64)\.)" + "\b(?:(?:299)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.64.299.0/24
$LearningCentreN1="\b(?:(?:10)\.)" + "\b(?:(?:69)\.)" + "\b(?:(?:137)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.69.137.0/24
$NissanWoodmead="\b(?:(?:10)\.)" + "\b(?:(?:69)\.)" + "\b(?:(?:43)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.69.43.0/24
$MercedesFountains="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:1)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.1.0/24
$ChryslerJeepWonderboom="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:142)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.142.0/24
$AudiArcadia="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:147)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.147.0/24
$McCarthyFordAndMazdaSilverlakePretoria="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:149)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.149.0/24
$LexusLynwood="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:150)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.150.0/24
$AudiWonderboom="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:151)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.151.0/24
$SuzukiMenlyn="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:152)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.152.0/24
$VWWitbankCommercial="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:188)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.188.0/24
$MercedesWonderboom="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:192)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.192.0/24
$MercedesLifestyleCentre="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:193)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.193.0/24
$ValueCentrePolokwane="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:194)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.194.0/24
$ChryslerJeepMenlyn="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:195)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.195.0/24
$GMMontana="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:196)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.196.0/24
$MccarthyLearningCenter="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:197)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.197.0/24
$GMHatfield="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:202)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.202.0/24
$VWChurchStreetArcadiaPretoria="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:204)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.204.0/24
$VWMasterCarsGezina="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:205)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.205.0/24
$VWGezina="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:206)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.206.0/24
$MitsubishiBrooklyn="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:215)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.215.0/24
$AudiCentreWestRand="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:220)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.220.0/24
$ChryslerJeepCenturion="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:222)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.222.0/24
$AudiChurchStreetPretoria="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:223)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.223.0/24
$AudiMenlyn="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:224)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.224.0/24
$ToyotaArcadiaAutomark="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:225)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.225.0/24
$VWMenlyn="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:226)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.226.0/24
$VWPrincesStreet="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:227)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.227.0/24
$McCarthyKuneneTruckCentre="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:231)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.231.0/24
$MercedesKunene="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:231)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.231.0/24
$AudiCenturion="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:232)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.232.0/24
$AutoHausCenturion="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:232)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.232.0/24
$ToyotaArcadia="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:234)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.234.0/24
$ValueCentrePretoriaCentral="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:235)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.235.0/24
$GMSilverton="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:236)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.236.0/24
$ToyotaGezina="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:237)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.237.0/24
$ToyotaSinoville="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:238)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.238.0/24
$VWMiddelburg="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:239)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.239.0/24
$VWWitbank="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:240)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.240.0/24
$MercedesCenturion="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:243)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.243.0/24
$ToyotaFitmentCentreGezina="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:245)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.245.0/24
$ToyotaCenturion="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:251)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.251.0/24
$MercedesPretoriaWestParts="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:253)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.253.0/24
$GMMenlyn="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:254)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.254.0/24
$GMPretoria="\b(?:(?:10)\.)" + "\b(?:(?:96)\.)" + "\b(?:(?:254)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.96.254.0/24
$ToyotaHatfield="\b(?:(?:10)\.)" + "\b(?:(?:97)\.)" + "\b(?:(?:4)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" #10.97.4.0/24



########################
# Set the Location OUs #
########################

# Disabled OU
###   $DisabledDN = "OU=Disabled,DC=yourdomain,DC=com"

# OU Locations
$PreOwnedStellenboschDN = "OU=Computers,OU=Pre-Owned Stellenbosch,OU=McCarthy Pre-Owned,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$SuzukiPlumsteadDN = "OU=Computers,OU=Suzuki Plumstead,OU=McCarthy Suzuki,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaTableviewDN = "OU=Computers,OU=Toyota Tableview,OU=McCarthy Toyota,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaN1CityStockyardDN = "OU=Computers,OU=Toyota N1 City Stockyard,OU=McCarthy Toyota,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$BurchmoresCarAuctionsCapeDN = "OU=Computers,OU=Burchmores Car Auctions Cape,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ForsdicksARCCapeDN = "OU=Computers,OU=Forsdicks ARC Cape,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWParrowDN = "OU=Computers,OU=VW Parrow,OU=McCarthy Volkswagen,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$LandRoverN1CityDN = "OU=Computers,OU=LandRover N1 City,OU=McCarthy LandRover Volvo,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ValueCentreParrowDN = "OU=Computers,OU=Value Centre Parrow,OU=McCarthy Value Centre,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaAutomarkN1CityDN = "OU=Computers,OU=Toyota Automark N1 City,OU=McCarthy Toyota,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaN1CityDN = "OU=Computers,OU=Toyota N1 City,OU=McCarthy Toyota,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaPartsWarehouseParrowDN = "OU=Computers,OU=Toyota Parts Warehouse Parrow,OU=McCarthy Toyota,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaPaarlDN = "OU=Computers,OU=Toyota Paarl,OU=McCarthy Toyota,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$KingsmeadDN = "OU=Computers,OU=Kingsmead,OU=McCarthy Lexus,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaKingsmeadDN = "OU=Computers,OU=Toyota Kingsmead,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaHinoPMBDN = "OU=Computers,OU=Toyota Hino PMB,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyPreOwnedWonderboomDN = "OU=Computers,OU=McCarthy Pre-Owned Wonderboom,OU=McCarthy Pre-Owned,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWAudiWonderboomDN = "OU=Computers,OU=VW Audi Wonderboom,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaEmpangeniDN = "OU=Computers,OU=Toyota Empangeni,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$InyangaMotorsVryheidDN = "OU=Computers,OU=Inyanga Motors Vryheid,OU=McCarthy Daimler Chrysler and Jeep,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$InyangaMotorsEmpangeniDN = "OU=Computers,OU=Inyanga Motors Empangeni,OU=McCarthy Daimler Chrysler and Jeep,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ValueCentreBloemfonteinDN = "OU=Computers,OU=Value Centre Bloemfontein,OU=McCarthy Value Centre,OU=Bloemfontein Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$SuzukiBloemfonteinDN = "OU=Computers,OU=Suzuki Bloemfontein,OU=Bloemfontein Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MotorCityPMBDN = "OU=Computers,OU=Motor City PMB,OU=McCarthy Renault,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaPMBDN = "OU=Computers,OU=Toyota PMB,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyInsuranceServicesDN = "OU=Computers,OU=McCarthy Insurance Services,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaPMBAutomarkDN = "OU=Computers,OU=Toyota PMB Automark,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$TechnicalTrainingPinetownDN = "OU=Computers,OU=Technical Training Pinetown,OU=McCarthy Training,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$TrainingDerbyDownsDN = "OU=Computers,OU=Training Derby Downs,OU=McCarthy Training,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AudiUmhlangaDN = "OU=Computers,OU=Audi Umhlanga,OU=McCarthy Audi,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AudiCenterDurbanDN = "OU=Computers,OU=Audi Center Durban,OU=McCarthy Audi,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$LandRoverDurbanDN = "OU=Computers,OU=LandRover  Durban,OU=McCarthy LandRover,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWUmhlangaDN = "OU=Computers,OU=VW Umhlanga,OU=McCarthy Volkswagen,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$BurchmoresDurbanUmgeniDN = "OU=Computers,OU=Burchmores Durban - Umgeni,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaPinetownDN = "OU=Computers,OU=Toyota Pinetown,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWDurbanDN = "OU=Computers,OU=VW Durban,OU=McCarthy Volkswagen,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AutomarkGreyvilleDN = "OU=Computers,OU=Automark Greyville,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$HeadOfficeDurbanDN = "OU=Computers,OU=Head Office Durban,OU=McCarthy Insurance,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthySupportServicesDBNDN = "OU=Computers,OU=McCarthy Support Services DBN,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$NissanGatewayDN = "OU=Computers,OU=Nissan Gateway,OU=Mccarthy Nissan,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AutomarkMobeniDN = "OU=Computers,OU=Automark Mobeni,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaMobeniDN = "OU=Computers,OU=Toyota Mobeni,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaTrucksWestmeadDN = "OU=Computers,OU=Toyota Trucks Westmead,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AutomarkDurbanNorthDN = "OU=Computers,OU=Automark Durban North,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaDurbanNorthDN = "OU=Computers,OU=Toyota Durban North,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaGreyvilleDN = "OU=Computers,OU=Toyota Greyville,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AutomarkBalitoDN = "OU=Computers,OU=Automark Balito,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaBallitoDN = "OU=Computers,OU=Toyota Ballito,OU=McCarthy Toyota,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyAutoBodyRepairCentreDN = "OU=Computers,OU=McCarthy Auto Body Repair Centre,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyKiaKimberleyDN = "OU=Computers,OU=McCarthy Kia Kimberley,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyFotonDN = "OU=Computers,OU=McCarthy Foton,OU=McCarthy Value Centre,OU=Bloemfontein Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyFordAndMazdaTheGlenDN = "OU=Computers,OU=McCarthy Ford And Mazda The Glen,OU=McCarthy Ford and Mazda,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyPreOwnedEdenvaleDN = "OU=Computers,OU=McCarthy Pre-Owned Edenvale,OU=McCarthy Pre-Owned,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaMidrandDN = "OU=Computers,OU=Toyota Midrand,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$SuzukiMidrandDN = "OU=Computers,OU=Suzuki Midrand,OU=McCarthy Suzuki,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MitsubishiMidrandDN = "OU=Computers,OU=Mitsubishi Midrand,OU=McCarthy Mitsubishi,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyCommercialVehiclesAlbertonDN = "OU=Computers,OU=McCarthy Commercial Vehicles Alberton,OU=McCarthy Commercial,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWConstantiaDN = "OU=Computers,OU=VW Constantia,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$NissanPreOwnedRandburgDN = "OU=Computers,OU=Nissan Pre-Owned Randburg,OU=McCarthy Nissan,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$NissanRandburgDN = "OU=Computers,OU=Nissan Randburg,OU=McCarthy Nissan,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$NissanJHBCityDN = "OU=Computers,OU=Nissan JHB City,OU=McCarthy Nissan,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWSilveroaksDN = "OU=Computers,OU=VW Silveroaks,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$NissanMountiesDN = "OU=Computers,OU=Nissan Mounties,OU=McCarthy Nissan,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$NissanGermistonDN = "OU=Computers,OU=Nissan Germiston,OU=McCarthy Nissan,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthySupportServicesJHBDN = "OU=Computers,OU=McCarthy Support Services JHB,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWRoodepoortDN = "OU=Computers,OU=VW Roodepoort,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$BurchmoresSandtonDN = "OU=Computers,OU=Burchmores Sandton,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyCommercialVehiclesBoksburgDN = "OU=Computers,OU=McCarthy Commercial Vehicles Boksburg,OU=McCarthy Commercial,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaWoodmeadDN = "OU=Computers,OU=Toyota Woodmead,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$TechnicalTrainingMidrandDN = "OU=Computers,OU=Technical Training Midrand,OU=McCarthy Training,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaEdenvaleDN = "OU=Computers,OU=Toyota Edenvale,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$LandRoverConstantiaKloofDN = "OU=Computers,OU=LandRover Constantia Kloof,OU=McCarthy LandRover,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$LandRoverMidrandDN = "OU=Computers,OU=LandRover Midrand,OU=McCarthy LandRover,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaBrumaDN = "OU=Computers,OU=Toyota Bruma,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaHinoSelbyDN = "OU=Computers,OU=Toyota Hino Selby,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyCommercialVehiclesKlipstoneDN = "OU=Computers,OU=McCarthy Commercial Vehicles Klipstone,OU=McCarthy Commercial,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$LearningCentreN1DN = "OU=Computers,OU=Learning Centre N1,OU=Cape Town Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$NissanWoodmeadDN = "OU=Computers,OU=Nissan Woodmead,OU=McCarthy Nissan,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MercedesFountainsDN = "OU=Computers,OU=Mercedes Fountains,OU=McCarthy Daimler Chrysler and Jeep,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ChryslerJeepWonderboomDN = "OU=Computers,OU=Chrysler Jeep Wonderboom,OU=McCarthy Daimler Chrysler and Jeep,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AudiArcadiaDN = "OU=Computers,OU=Audi Arcadia,OU=McCarthy Audi,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyFordAndMazdaSilverlakePretoriaDN = "OU=Computers,OU=McCarthy Ford And Mazda Silverlake Pretoria,OU=McCarthy Ford and Mazda,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$LexusLynwoodDN = "OU=Computers,OU=Lexus Lynwood,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AudiWonderboomDN = "OU=Computers,OU=Audi Wonderboom,OU=McCarthy Audi,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$SuzukiMenlynDN = "OU=Computers,OU=Suzuki Menlyn,OU=McCarthy Suzuki,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWWitbankCommercialDN = "OU=Computers,OU=VW Witbank Commercial,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MercedesWonderboomDN = "OU=Computers,OU=Mercedes Wonderboom,OU=McCarthy Daimler Chrysler and Jeep,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MercedesLifestyleCentreDN = "OU=Computers,OU=Mercedes Lifestyle Centre,OU=McCarthy Daimler Chrysler and Jeep,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ValueCentrePolokwaneDN = "OU=Computers,OU=Value Centre Polokwane,OU=McCarthy Value Centre,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ChryslerJeepMenlynDN = "OU=Computers,OU=Chrysler Jeep Menlyn,OU=McCarthy Daimler Chrysler and Jeep,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$GMMontanaDN = "OU=Computers,OU=GM Montana,OU=McCarthy General Motors,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MccarthyLearningCenterDN = "OU=Computers,OU=Mccarthy Learning Center,OU=McCarthy Training,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$GMHatfieldDN = "OU=Computers,OU=GM Hatfield,OU=McCarthy General Motors,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWChurchStreetArcadiaPretoriaDN = "OU=Computers,OU=VW Church Street Arcadia Pretoria,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWMasterCarsGezinaDN = "OU=Computers,OU=VW MasterCars Gezina,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWGezinaDN = "OU=Computers,OU=VW Gezina,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MitsubishiBrooklynDN = "OU=Computers,OU=Mitsubishi Brooklyn,OU=McCarthy Mitsubishi,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AudiCentreWestRandDN = "OU=Computers,OU=Audi Centre WestRand,OU=McCarthy Audi,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ChryslerJeepCenturionDN = "OU=Computers,OU=Chrysler Jeep Centurion,OU=McCarthy Daimler Chrysler and Jeep,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AudiChurchStreetPretoriaDN = "OU=Computers,OU=Audi Church Street Pretoria,OU=McCarthy Audi,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AudiMenlynDN = "OU=Computers,OU=Audi Menlyn,OU=McCarthy Audi,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaArcadiaAutomarkDN = "OU=Computers,OU=Toyota Arcadia Automark,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWMenlynDN = "OU=Computers,OU=VW Menlyn,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWPrincesStreetDN = "OU=Computers,OU=VW Princes Street,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyKuneneTruckCentreDN = "OU=Computers,OU=McCarthy Kunene Truck Centre,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MercedesKuneneDN = "OU=Computers,OU=Mercedes Kunene,OU=McCarthy Daimler Chrysler and Jeep,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AudiCenturionDN = "OU=Computers,OU=Audi Centurion,OU=McCarthy Audi,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AutoHausCenturionDN = "OU=Computers,OU=AutoHaus Centurion,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaArcadiaDN = "OU=Computers,OU=Toyota Arcadia,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ValueCentrePretoriaCentralDN = "OU=Computer,OU=Value Centre Pretoria Central,OU=McCarthy Value Centre,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$GMSilvertonDN = "OU=Computers,OU=GM Silverton,OU=McCarthy General Motors,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaGezinaDN = "OU=Computers,OU=Toyota Gezina,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaSinovilleDN = "OU=Computers,OU=Toyota Sinoville,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWMiddelburgDN = "OU=Computers,OU=VW Middelburg,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWWitbankDN = "OU=Computers,OU=VW Witbank,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MercedesCenturionDN = "OU=Computers,OU=Mercedes Centurion,OU=McCarthy Daimler Chrysler and Jeep,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaFitmentCentreGezinaDN = "OU=Computers,OU=Toyota Fitment Centre Gezina,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaCenturionDN = "OU=Computers,OU=Toyota Centurion,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MercedesPretoriaWestPartsDN = "OU=Computers,OU=Mercedes Pretoria West (Parts),OU=McCarthy Daimler Chrysler and Jeep,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$GMMenlynDN = "OU=Computers,OU=GM Menlyn,OU=McCarthy General Motors,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$GMPretoriaDN = "OU=Computers,OU=GM Pretoria,OU=McCarthy General Motors,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$ToyotaHatfieldDN = "OU=Computers,OU=Toyota Hatfield,OU=McCarthy Toyota,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$AlfaFiatGermistonDN = "OU=Computers,OU=Alfa & Fiat Germiston,OU=McCarthy Nissan,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$HRDerbyDownsDN = "OU=Computers,OU=HR Derby Downs,OU=McCarthy HR,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyMobileUsersDN = "OU=Computers,OU=McCarthy Mobile Users,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyPreOwnedAnnlinDN = "OU=Computers,OU=McCarthy Pre-Owned Annlin,OU=McCarthy Pre-Owned,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyPreOwnedPretoriaDN = "OU=Computers,OU=McCarthy Pre-Owned Pretoria,OU=McCarthy Pre-Owned,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyRiskControlDN = "OU=Computers,OU=McCarthy Risk Control,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$McCarthyValueCentreTAKuneneSandtonDN = "OU=Computers,OU=McCarthy Value Centre T/A Kunene Sandton,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$MobileUsersDN = "OU=Computers,OU=Mobile Users,OU=McCarthy Insurance,OU=Durban Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"
$VWMastercarsDN = "OU=Computers,OU=VW Mastercars,OU=McCarthy Volkswagen,OU=Johannesburg Region,OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local"


###############
# The process #
###############

# Query Active Directory for Computers running Windows 7 (Any version) and move the objects to the correct OU based on IP
Get-ADComputer -Filter { OperatingSystem -like "Windows *" } -SearchScope Subtree -SearchBase "CN=Computers,DC=McCarthyLtd,DC=Local"  | ForEach-Object {

	# Ignore Error Messages and continue on
	trap [System.Net.Sockets.SocketException] { continue; }

	# Set variables for Name and current OU
	$ComputerName = $_.Name
	$ComputerDN = $_.distinguishedName
	### $ComputerPasswordLastSet = $_.PasswordLastSet
	$ComputerContainer = $ComputerDN.Replace( "CN=$ComputerName," , "")

	# If the computer is more than 90 days off the network, remove the computer object
	###   if ($ComputerPasswordLastSet -le $veryold) { 
	### 	Remove-ADObject -Identity $ComputerDN
	###     }

	# Check to see if it is an "old" computer account and move it to the Disabled\Computers OU
	###   if ($ComputerPasswordLastSet -le $old) { 
	###   	$DestinationDN = $DisabledDN
	###   	Move-ADObject -Identity $ComputerDN -TargetPath $DestinationDN
	###    }

	# Query DNS for IP 
	# First we clear the previous IP. If the lookup fails it will retain the previous IP and incorrectly identify the subnet
	$IP = $NULL
	$IP = [System.Net.Dns]::GetHostAddresses("$ComputerName")

	# Use the $IPLocation to determine the computer's destination network location
	#
	#
	if ($IP -match $PreOwnedStellenbosch) {
$DestinationDN = $PreOwnedStellenboschDN
}
Elseif ($IP -match $SuzukiPlumstead) {
$DestinationDN = $SuzukiPlumsteadDN
}
Elseif ($IP -match $ToyotaTableview) {
$DestinationDN = $ToyotaTableviewDN
}
Elseif ($IP -match $ToyotaN1CityStockyard) {
$DestinationDN = $ToyotaN1CityStockyardDN
}
Elseif ($IP -match $BurchmoresCarAuctionsCape) {
$DestinationDN = $BurchmoresCarAuctionsCapeDN
}
Elseif ($IP -match $ForsdicksARCCape) {
$DestinationDN = $ForsdicksARCCapeDN
}
Elseif ($IP -match $VWParrow) {
$DestinationDN = $VWParrowDN
}
Elseif ($IP -match $LandRoverN1City) {
$DestinationDN = $LandRoverN1CityDN
}
Elseif ($IP -match $ValueCentreParrow) {
$DestinationDN = $ValueCentreParrowDN
}
Elseif ($IP -match $ToyotaAutomarkN1City) {
$DestinationDN = $ToyotaAutomarkN1CityDN
}
Elseif ($IP -match $ToyotaN1City) {
$DestinationDN = $ToyotaN1CityDN
}
Elseif ($IP -match $ToyotaPartsWarehouseParrow) {
$DestinationDN = $ToyotaPartsWarehouseParrowDN
}
Elseif ($IP -match $ToyotaPaarl) {
$DestinationDN = $ToyotaPaarlDN
}
Elseif ($IP -match $Kingsmead) {
$DestinationDN = $KingsmeadDN
}
Elseif ($IP -match $ToyotaKingsmead) {
$DestinationDN = $ToyotaKingsmeadDN
}
Elseif ($IP -match $ToyotaHinoPMB) {
$DestinationDN = $ToyotaHinoPMBDN
}
Elseif ($IP -match $McCarthyPreOwnedWonderboom) {
$DestinationDN = $McCarthyPreOwnedWonderboomDN
}
Elseif ($IP -match $VWAudiWonderboom) {
$DestinationDN = $VWAudiWonderboomDN
}
Elseif ($IP -match $ToyotaEmpangeni) {
$DestinationDN = $ToyotaEmpangeniDN
}
Elseif ($IP -match $InyangaMotorsVryheid) {
$DestinationDN = $InyangaMotorsVryheidDN
}
Elseif ($IP -match $InyangaMotorsEmpangeni) {
$DestinationDN = $InyangaMotorsEmpangeniDN
}
Elseif ($IP -match $ValueCentreBloemfontein) {
$DestinationDN = $ValueCentreBloemfonteinDN
}
Elseif ($IP -match $SuzukiBloemfontein) {
$DestinationDN = $SuzukiBloemfonteinDN
}
Elseif ($IP -match $MotorCityPMB) {
$DestinationDN = $MotorCityPMBDN
}
Elseif ($IP -match $ToyotaPMB) {
$DestinationDN = $ToyotaPMBDN
}
Elseif ($IP -match $McCarthyInsuranceServices) {
$DestinationDN = $McCarthyInsuranceServicesDN
}
Elseif ($IP -match $ToyotaPMBAutomark) {
$DestinationDN = $ToyotaPMBAutomarkDN
}
Elseif ($IP -match $TechnicalTrainingPinetown) {
$DestinationDN = $TechnicalTrainingPinetownDN
}
Elseif ($IP -match $TrainingDerbyDowns) {
$DestinationDN = $TrainingDerbyDownsDN
}
Elseif ($IP -match $AudiUmhlanga) {
$DestinationDN = $AudiUmhlangaDN
}
Elseif ($IP -match $AudiCenterDurban) {
$DestinationDN = $AudiCenterDurbanDN
}
Elseif ($IP -match $LandRoverDurban) {
$DestinationDN = $LandRoverDurbanDN
}
Elseif ($IP -match $VWUmhlanga) {
$DestinationDN = $VWUmhlangaDN
}
Elseif ($IP -match $BurchmoresDurbanUmgeni) {
$DestinationDN = $BurchmoresDurbanUmgeniDN
}
Elseif ($IP -match $ToyotaPinetown) {
$DestinationDN = $ToyotaPinetownDN
}
Elseif ($IP -match $VWDurban) {
$DestinationDN = $VWDurbanDN
}
Elseif ($IP -match $AutomarkGreyville) {
$DestinationDN = $AutomarkGreyvilleDN
}
Elseif ($IP -match $HeadOfficeDurban) {
$DestinationDN = $HeadOfficeDurbanDN
}
Elseif ($IP -match $McCarthySupportServicesDBN) {
$DestinationDN = $McCarthySupportServicesDBNDN
}
Elseif ($IP -match $NissanGateway) {
$DestinationDN = $NissanGatewayDN
}
Elseif ($IP -match $AutomarkMobeni) {
$DestinationDN = $AutomarkMobeniDN
}
Elseif ($IP -match $ToyotaMobeni) {
$DestinationDN = $ToyotaMobeniDN
}
Elseif ($IP -match $ToyotaTrucksWestmead) {
$DestinationDN = $ToyotaTrucksWestmeadDN
}
Elseif ($IP -match $AutomarkDurbanNorth) {
$DestinationDN = $AutomarkDurbanNorthDN
}
Elseif ($IP -match $ToyotaDurbanNorth) {
$DestinationDN = $ToyotaDurbanNorthDN
}
Elseif ($IP -match $ToyotaGreyville) {
$DestinationDN = $ToyotaGreyvilleDN
}
Elseif ($IP -match $AutomarkBalito) {
$DestinationDN = $AutomarkBalitoDN
}
Elseif ($IP -match $ToyotaBallito) {
$DestinationDN = $ToyotaBallitoDN
}
Elseif ($IP -match $McCarthyAutoBodyRepairCentre) {
$DestinationDN = $McCarthyAutoBodyRepairCentreDN
}
Elseif ($IP -match $McCarthyKiaKimberley) {
$DestinationDN = $McCarthyKiaKimberleyDN
}
Elseif ($IP -match $McCarthyFoton) {
$DestinationDN = $McCarthyFotonDN
}
Elseif ($IP -match $McCarthyFordAndMazdaTheGlen) {
$DestinationDN = $McCarthyFordAndMazdaTheGlenDN
}
Elseif ($IP -match $McCarthyPreOwnedEdenvale) {
$DestinationDN = $McCarthyPreOwnedEdenvaleDN
}
Elseif ($IP -match $ToyotaMidrand) {
$DestinationDN = $ToyotaMidrandDN
}
Elseif ($IP -match $SuzukiMidrand) {
$DestinationDN = $SuzukiMidrandDN
}
Elseif ($IP -match $MitsubishiMidrand) {
$DestinationDN = $MitsubishiMidrandDN
}
Elseif ($IP -match $McCarthyCommercialVehiclesAlberton) {
$DestinationDN = $McCarthyCommercialVehiclesAlbertonDN
}
Elseif ($IP -match $VWConstantia) {
$DestinationDN = $VWConstantiaDN
}
Elseif ($IP -match $NissanPreOwnedRandburg) {
$DestinationDN = $NissanPreOwnedRandburgDN
}
Elseif ($IP -match $NissanRandburg) {
$DestinationDN = $NissanRandburgDN
}
Elseif ($IP -match $NissanJHBCity) {
$DestinationDN = $NissanJHBCityDN
}
Elseif ($IP -match $VWSilveroaks) {
$DestinationDN = $VWSilveroaksDN
}
Elseif ($IP -match $NissanMounties) {
$DestinationDN = $NissanMountiesDN
}
Elseif ($IP -match $NissanGermiston) {
$DestinationDN = $NissanGermistonDN
}
Elseif ($IP -match $McCarthySupportServicesJHB) {
$DestinationDN = $McCarthySupportServicesJHBDN
}
Elseif ($IP -match $VWRoodepoort) {
$DestinationDN = $VWRoodepoortDN
}
Elseif ($IP -match $BurchmoresSandton) {
$DestinationDN = $BurchmoresSandtonDN
}
Elseif ($IP -match $McCarthyCommercialVehiclesBoksburg) {
$DestinationDN = $McCarthyCommercialVehiclesBoksburgDN
}
Elseif ($IP -match $ToyotaWoodmead) {
$DestinationDN = $ToyotaWoodmeadDN
}
Elseif ($IP -match $TechnicalTrainingMidrand) {
$DestinationDN = $TechnicalTrainingMidrandDN
}
Elseif ($IP -match $ToyotaEdenvale) {
$DestinationDN = $ToyotaEdenvaleDN
}
Elseif ($IP -match $LandRoverConstantiaKloof) {
$DestinationDN = $LandRoverConstantiaKloofDN
}
Elseif ($IP -match $LandRoverMidrand) {
$DestinationDN = $LandRoverMidrandDN
}
Elseif ($IP -match $ToyotaBruma) {
$DestinationDN = $ToyotaBrumaDN
}
Elseif ($IP -match $ToyotaHinoSelby) {
$DestinationDN = $ToyotaHinoSelbyDN
}
Elseif ($IP -match $McCarthyCommercialVehiclesKlipstone) {
$DestinationDN = $McCarthyCommercialVehiclesKlipstoneDN
}
Elseif ($IP -match $LearningCentreN1) {
$DestinationDN = $LearningCentreN1DN
}
Elseif ($IP -match $NissanWoodmead) {
$DestinationDN = $NissanWoodmeadDN
}
Elseif ($IP -match $MercedesFountains) {
$DestinationDN = $MercedesFountainsDN
}
Elseif ($IP -match $ChryslerJeepWonderboom) {
$DestinationDN = $ChryslerJeepWonderboomDN
}
Elseif ($IP -match $AudiArcadia) {
$DestinationDN = $AudiArcadiaDN
}
Elseif ($IP -match $McCarthyFordAndMazdaSilverlakePretoria) {
$DestinationDN = $McCarthyFordAndMazdaSilverlakePretoriaDN
}
Elseif ($IP -match $LexusLynwood) {
$DestinationDN = $LexusLynwoodDN
}
Elseif ($IP -match $AudiWonderboom) {
$DestinationDN = $AudiWonderboomDN
}
Elseif ($IP -match $SuzukiMenlyn) {
$DestinationDN = $SuzukiMenlynDN
}
Elseif ($IP -match $VWWitbankCommercial) {
$DestinationDN = $VWWitbankCommercialDN
}
Elseif ($IP -match $MercedesWonderboom) {
$DestinationDN = $MercedesWonderboomDN
}
Elseif ($IP -match $MercedesLifestyleCentre) {
$DestinationDN = $MercedesLifestyleCentreDN
}
Elseif ($IP -match $ValueCentrePolokwane) {
$DestinationDN = $ValueCentrePolokwaneDN
}
Elseif ($IP -match $ChryslerJeepMenlyn) {
$DestinationDN = $ChryslerJeepMenlynDN
}
Elseif ($IP -match $GMMontana) {
$DestinationDN = $GMMontanaDN
}
Elseif ($IP -match $MccarthyLearningCenter) {
$DestinationDN = $MccarthyLearningCenterDN
}
Elseif ($IP -match $GMHatfield) {
$DestinationDN = $GMHatfieldDN
}
Elseif ($IP -match $VWChurchStreetArcadiaPretoria) {
$DestinationDN = $VWChurchStreetArcadiaPretoriaDN
}
Elseif ($IP -match $VWMasterCarsGezina) {
$DestinationDN = $VWMasterCarsGezinaDN
}
Elseif ($IP -match $VWGezina) {
$DestinationDN = $VWGezinaDN
}
Elseif ($IP -match $MitsubishiBrooklyn) {
$DestinationDN = $MitsubishiBrooklynDN
}
Elseif ($IP -match $AudiCentreWestRand) {
$DestinationDN = $AudiCentreWestRandDN
}
Elseif ($IP -match $ChryslerJeepCenturion) {
$DestinationDN = $ChryslerJeepCenturionDN
}
Elseif ($IP -match $AudiChurchStreetPretoria) {
$DestinationDN = $AudiChurchStreetPretoriaDN
}
Elseif ($IP -match $AudiMenlyn) {
$DestinationDN = $AudiMenlynDN
}
Elseif ($IP -match $ToyotaArcadiaAutomark) {
$DestinationDN = $ToyotaArcadiaAutomarkDN
}
Elseif ($IP -match $VWMenlyn) {
$DestinationDN = $VWMenlynDN
}
Elseif ($IP -match $VWPrincesStreet) {
$DestinationDN = $VWPrincesStreetDN
}
Elseif ($IP -match $McCarthyKuneneTruckCentre) {
$DestinationDN = $McCarthyKuneneTruckCentreDN
}
Elseif ($IP -match $MercedesKunene) {
$DestinationDN = $MercedesKuneneDN
}
Elseif ($IP -match $AudiCenturion) {
$DestinationDN = $AudiCenturionDN
}
Elseif ($IP -match $AutoHausCenturion) {
$DestinationDN = $AutoHausCenturionDN
}
Elseif ($IP -match $ToyotaArcadia) {
$DestinationDN = $ToyotaArcadiaDN
}
Elseif ($IP -match $ValueCentrePretoriaCentral) {
$DestinationDN = $ValueCentrePretoriaCentralDN
}
Elseif ($IP -match $GMSilverton) {
$DestinationDN = $GMSilvertonDN
}
Elseif ($IP -match $ToyotaGezina) {
$DestinationDN = $ToyotaGezinaDN
}
Elseif ($IP -match $ToyotaSinoville) {
$DestinationDN = $ToyotaSinovilleDN
}
Elseif ($IP -match $VWMiddelburg) {
$DestinationDN = $VWMiddelburgDN
}
Elseif ($IP -match $VWWitbank) {
$DestinationDN = $VWWitbankDN
}
Elseif ($IP -match $MercedesCenturion) {
$DestinationDN = $MercedesCenturionDN
}
Elseif ($IP -match $ToyotaFitmentCentreGezina) {
$DestinationDN = $ToyotaFitmentCentreGezinaDN
}
Elseif ($IP -match $ToyotaCenturion) {
$DestinationDN = $ToyotaCenturionDN
}
Elseif ($IP -match $MercedesPretoriaWestParts) {
$DestinationDN = $MercedesPretoriaWestPartsDN
}
Elseif ($IP -match $GMMenlyn) {
$DestinationDN = $GMMenlynDN
}
Elseif ($IP -match $GMPretoria) {
$DestinationDN = $GMPretoriaDN
}
Elseif ($IP -match $ToyotaHatfield) {
$DestinationDN = $ToyotaHatfieldDN
}
Elseif ($IP -match $AlfaFiatGermiston) {
$DestinationDN = $AlfaFiatGermistonDN
}
Elseif ($IP -match $HRDerbyDowns) {
$DestinationDN = $HRDerbyDownsDN
}
Elseif ($IP -match $McCarthyMobileUsers) {
$DestinationDN = $McCarthyMobileUsersDN
}
Elseif ($IP -match $McCarthyPreOwnedAnnlin) {
$DestinationDN = $McCarthyPreOwnedAnnlinDN
}
Elseif ($IP -match $McCarthyPreOwnedPretoria) {
$DestinationDN = $McCarthyPreOwnedPretoriaDN
}
Elseif ($IP -match $McCarthyRiskControl) {
$DestinationDN = $McCarthyRiskControlDN
}
Elseif ($IP -match $McCarthyValueCentreTAKuneneSandton) {
$DestinationDN = $McCarthyValueCentreTAKuneneSandtonDN
}
Elseif ($IP -match $MobileUsers) {
$DestinationDN = $MobileUsersDN
}
Elseif ($IP -match $VWMastercars) {
$DestinationDN = $VWMastercarsDN
}

	}
	Elseif {
		# If the subnet does not match we should not move the computer so we do Nothing
		$DestinationDN = $ComputerContainer	
	}

	# Move the Computer object to the appropriate OU
	# If the IP is NULL we will trust it is an "old" or "very old" computer so we won't move it again
	if ($IP -ne $NULL) {
		Move-ADObject -Identity $ComputerDN -TargetPath $DestinationDN
	}