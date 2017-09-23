# A Short QGIS+MaxEnt Tutorial
This repository contains a short tutorial for learning species distribution modeling for conservation applications using Quantum GIS and MaxEnt in half a day. I prepared this documentation for the skills training sessions during the lab retreat of the [Applied Plant Ecology Lab](https://www.appliedplantecology.org), Department of Biological Sciences, National University of Singapore held on 25-28 September 2017 in Malacca, Malaysia.


## Table of Contents
- [Download and Installation](#download)
- [Study Area](#study_area)
- [Data Preparation](#data_preparation)
- [References](#references)
- [License](#license)
- [Want to Contribute?](#contribute)


<a name="download"></a>
## Download and Installation

#### Software
For this tutorial, download and install [QGIS](http://www.qgis.org/en/site/forusers/download.html) and [MaxEnt](https://biodiversityinformatics.amnh.org/open_source/maxent/), both of which are free and open-source software. For QGIS, download the version compatible with your machine's operating system. MaxEnt is a Java-based application and runs using various operating systems. The procedures shown in this tutorial uses a Mac OSX platform but it should be applicable to other operating systems.

#### Data
MaxEnt will require two types of input datasets:

1. **Species occurrence data.** The species occurrence records are the geographic point locations or coordinates of species observations. For this exercise, we will use the georeferenced database of selected threatened forest tree species in the Philippines compiled by [Ramos et al. (2011)](#ramos_etal_2011). Download the database from the World Agroforestry Centre/ICRAF Dataverse [here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/24818) (150 KB, CSV file).

2. **Environmental predictors.** The environmental covariates consist of raster data that contain either continuous or categorical values such as precipitation, temperature, elevation, etc. We will be using the [WorldClim](http://www.worldclim.org) raster datasets. WorldClim is a set of gridded global climate data layers, which can be used for mapping and ecological modeling. For this exercise, we will use [WorldClim v.1.4 Current conditions](http://www.worldclim.org/current) (or interpolations of observed data from 1960-1990). We will need the highest resolution data available provided at 30 arc-seconds (~1 km); hence click the `download by tile` link and choose Tile 210. After clicking the tile, download the GeoTIFF file formats of the [Altitude](http://biogeo.ucdavis.edu/data/climate/worldclim/1_4/tiles/cur/alt_210_tif.zip) (~2 MB, ZIP file) and [Bioclim](http://biogeo.ucdavis.edu/data/climate/worldclim/1_4/tiles/cur/bio_210_tif.zip) (~29 MB, ZIP file) layers. You can read [Hijmans et al. (2005)](#hijmans_etal_2005) for more information about the climate data layers.

To prepare the datasets, we will also need **administrative boundary** data. We can use the administrative boundary vector data from the [Global Administrative Database](http://www.gadm.org/country). On GADM's Download page, select "Philippines" and "Shapefile" from the *Country* and *Format* drop-down menus, respectively, and click the [download](http://biogeo.ucdavis.edu/data/gadm2.8/shp/PHL_adm_shp.zip) link provided (~22 MB, ZIP file).


<a name="study_area"></a>
## Study Area
**Polillo Islands, Quezon Province, Philippines.** The Polillo group of islands (approx. 14.861 N, 122.038 E) is situated in the northeast part of the Philippine archipelago. The Polillos comprise 27 small islands and islets, 25km off the east coast of Luzon. They form part of the Luzon Endemic Bird Area (EBA), ranked sixth in the world listing of critical EBAs [(Stattersfield et al. 2000)](#stattersfield_etal_1998), whilst also constituting a highly distinct sub-centre of endemicity. Amongst these Polillo-specific endemics are a frog, several reptiles and seven birds, including a goshawk, hornbill, and parrots. The islands also support important populations of globally threatened species (e.g. Philippine cockatoo, Gray’s monitor lizard, Philippine jade vine), and are accorded high priority in all independent reviews of Philippine conservation priority areas. More information about the conservation priorities in the Polillos here.


<a name="data_preparation"></a>
## Data Preparation

1. First, we will create subsets from the environmental rasters to focus our modeling over our study area. To do this, we will create a polygon shapefile containing the extent of the study area and use this shapefile to clip all the raster map layers. Follow these steps using QGIS:

    - Load the **PHL_adm2.shp** shapefile by adding a vector layer **`Layer > Add Layer > Add Vector Layer...`** menu. This displays the municipal-level administrative boundaries.

    - To select our areas of interest, we will select the municipalities from the attribute table. Open the attribute table of **PHL_adm2.shp** by right-clicking the shapefile and then selecting **`Open Attribute Table`** from the menu.

    - Inside the attribute table window, click the `Select features using an expression` icon. Once the `Select by expression` dialog box opens, enter the following expression:
    ```
     "NAME_2"  = 'Polillo' OR  "NAME_2"  = 'Burdeos' OR  "NAME_2"  = 'Panukulan' OR  "NAME_2"  = 'Patnanungan' OR  "NAME_2"  = 'Jomalig'
    ```
    ![data-prep1](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-prevfit-convergence.png)

    This will select the municipalities belonging to our study area. Check the attribute table if you have selected five records, which includes the following municipalities: Polillo, Burdeos, Panukulan, Patnanungan, and Jomalig towns.  

    - In the main QGIS window, right-click on **PHL_adm2.shp** and select **`Save As...`** from the menu. Once the **`Save vector layer as...`** dialog box opens, tick the `Save only selected features` to ensure that we save a new shapefile containing only the selected municipalities. Then, enter the file name of the output shapefile to your working directory, and click `OK`. The new shapefile should appear in the QGIS `Table of Contents` pane.

    - Then, we will create a polygon from the extent of the municipalities shapefile that we have just saved. Go to **`Vector > Research Tools > Polygon from Layer Extent`** menu.

      + Under the `Input Layer` drop-down menu, select the newly created study area shapefile.
      + Under the `Extent` input line, select **`Save to File`** from the menu to save the file in your working directory. Then, click `Run` to create another shapefile, which consists of a box covering the extent of the study area.

    - Next, go to **`Processing > Toolbox`** menu, which opens a `Processing Toolbox` pane. Search for the `Clip raster with polygon` function under the SAGA geoalgorithms and select this function. This will open the **`Clip Raster with Polygon`** dialog box.

      + Under the `Input` drop-down menu, select one of the raster layers, say **biol1_210.tif**.
      + Under the `Polygons` drop-down menu, select the box polygon shapefile.
      + Under the `Clipped` input line, select **`Save to File`** from the menu to save the file in your working directory. Change the output file type to **ASC** as this is the file type requirement used by MaxEnt. Then, click `Run` to generate the clipped raster file.

    Repeat this for all other raster layers by following the same process. You may also opt to run this through batch processing by clicking on the **`Run As a Batch Process...`** button.  

<a name="references"></a>
## References

<a name="hijmans_etal_2005"></a>
HIJMANS, R.J., CAMERON, S.E., PARRA, J.L., JONES, P.G. & JARVIS, A. (2005) Very high resolution interpolated climate surfaces for global land areas. *International Journal of Climatology*, 25, 1965–1978. [(DOI)](https://dx.doi.org/10.1002/joc.1276)

<a name="ramos_etal_2011"></a>
RAMOS, L.T., TORRES, A.M., PULHIN, F.B. & LASCO, R.D. (2011) Developing a georeferenced database of selected threatened forest tree species in the Philippines. *Philippine Journal of Science*, 141, 165–177. [(PDF)](http://philjournalsci.dost.gov.ph/pdf/pjs%20pdf/vol141no2/pdf/Developing_a_Georeferenced_Database.pdf)

<a name="stattersfield_etal_1998"></a>
STATTERSFIELD, A.J., CROSBY, M., LONG, A.J. & WEGE, D.C. (1998) *Endemic Bird Areas of the World: Priorities for Biodiversity Conservation*. The Burlington Press, Ltd., Cambridge, United Kingdom.


<a name="license"></a>
## License
Creative Commons Attribution 4.0 International [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Please note the Disclaimer of Warranties and Limitation of Liability under Section 5 of this license as follows:

> a. Unless otherwise separately undertaken by the Licensor, to the extent possible, the Licensor offers the Licensed Material as-is and as-available, and makes no representations or warranties of any kind concerning the Licensed Material, whether express, implied, statutory, or other. This includes, without limitation, warranties of title, merchantability, fitness for a particular purpose, non-infringement, absence of latent or other defects, accuracy, or the presence or absence of errors, whether or not known or discoverable. Where disclaimers of warranties are not allowed in full or in part, this disclaimer may not apply to You.
>
> b. To the extent possible, in no event will the Licensor be liable to You on any legal theory (including, without limitation, negligence) or otherwise for any direct, special, indirect, incidental, consequential, punitive, exemplary, or other losses, costs, expenses, or damages arising out of this Public License or use of the Licensed Material, even if the Licensor has been advised of the possibility of such losses, costs, expenses, or damages. Where a limitation of liability is not allowed in full or in part, this limitation may not apply to You.
>
> c. The disclaimer of warranties and limitation of liability provided above shall be interpreted in a manner that, to the extent possible, most closely approximates an absolute disclaimer and waiver of all liability.

<a name="contribute"></a>
## Want to Contribute?
In case you wish to contribute or suggest changes, please feel free to fork this repository. Commit your changes and submit a pull request. Thanks.
