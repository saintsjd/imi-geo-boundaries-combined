
#all: zip/tl_2013_us_county.zip zip/tl_2013_us_cbsa.zip zip/region-shp.zip zip/ne_10m_admin_1_states_provinces_lakes_shp.zip zip/ne_10m_admin_0_countries_lakes.zip zip/ne_50m_admin_1_states_provinces_lakes_shp.zip zip/ne_50m_admin_0_countries_lakes.zip
all: tmp/tl_2013_us_county_clipped.shp tmp/tl_2013_us_cbsa_clipped.shp shp/tl_2013_us_county.shp shp/tl_2013_us_cbsa.shp shp/region-shp.shp shp/ne_10m_admin_1_states_provinces_lakes_shp.shp shp/ne_10m_admin_0_countries_lakes.shp shp/ne_50m_admin_1_states_provinces_lakes_shp.shp shp/ne_50m_admin_0_countries_lakes.shp

clean:
	rm -rf shp
	rm -rf geojson
	rm -rf topojson

clobber: clean
	rm -rf zip
	rm -rf gz

tmp/imi_overview_map.shp: tmp/counties_us.shp tmp/states_ca_mx.shp
	mkdir -p $(dir $@)
	ogr2ogr $@ $<
	ogr2ogr -update -append $@ tmp/states_ca_mx.shp -nln imi_overview_map
	touch $@

tmp/counties_us.shp: tmp/tl_2013_us_county_clipped.shp tmp/states_us.shp
	ogr2ogr -sql "select CONCAT(s.country,'.',s.state_abbr,'.',c.countyfp) as id, s.country as country,s.region as region,s.state as state,s.state_abbr as state_abbr, s.statefp as statefp, c.NAME as county, c.COUNTYFP as countyfp FROM tl_2013_us_county_clipped c LEFT JOIN 'tmp/states_us.dbf'.states_us s ON c.STATEFP=s.statefp" $@ $<
	touch $@

tmp/states_ca_mx.shp: shp/ne_10m_admin_1_states_provinces_lakes_shp.shp
	ogr2ogr -sql "select code_hasc as id, iso_a2 as country,region_big as region,name as state,postal as state_abbr, SUBSTR(code_local,3,2) as statefp FROM ne_10m_admin_1_states_provinces_lakes_shp where iso_a2 IN ('CA', 'MX')" $@ $<
	touch $@
tmp/states_us.shp: shp/ne_10m_admin_1_states_provinces_lakes_shp.shp
	ogr2ogr -sql "select iso_a2 as country,region_big as region,name as state,postal as state_abbr, SUBSTR(code_local,3,2) as statefp,code_hasc as id FROM ne_10m_admin_1_states_provinces_lakes_shp where iso_a2 IN ('US')" $@ $<
	touch $@

tmp/tl_2013_us_county_clipped.shp: shp/ne_10m_admin_0_countries_lakes.shp shp/tl_2013_us_county.shp
	mkdir -p $(dir $@)
	ogr2ogr -progress -clipsrc shp/ne_10m_admin_0_countries_lakes.shp -clipsrcwhere "adm0_a3='USA'" $@ shp/tl_2013_us_county.shp
	touch $@
tmp/tl_2013_us_cbsa_clipped.shp: shp/ne_10m_admin_0_countries_lakes.shp shp/tl_2013_us_cbsa.shp
	mkdir -p $(dir $@)
	ogr2ogr -progress -clipsrc shp/ne_10m_admin_0_countries_lakes.shp -clipsrcwhere "adm0_a3='USA'" $@ shp/tl_2013_us_cbsa.shp
	touch $@

shp/%.shp: zip/%.zip
	mkdir -p $(dir $@)
	unzip -d shp $<
	touch $@

zip/ne_50m_admin_0_countries_lakes.zip:
	mkdir -p $(dir $@)
	wget "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_countries_lakes.zip" -O $@.download
	mv $@.download $@

zip/ne_50m_admin_1_states_provinces_lakes_shp.zip:
	mkdir -p $(dir $@)
	wget "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_1_states_provinces_lakes_shp.zip" -O $@.download
	mv $@.download $@

zip/ne_10m_admin_0_countries_lakes.zip:
	mkdir -p $(dir $@)
	wget "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries_lakes.zip" -O $@.download
	mv $@.download $@

zip/ne_10m_admin_1_states_provinces_lakes_shp.zip:
	mkdir -p $(dir $@)
	wget "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_1_states_provinces_lakes_shp.zip" -O $@.download
	mv $@.download $@

zip/tl_2013_us_county.zip:
	mkdir -p $(dir $@)
	wget "ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUNTY/tl_2013_us_county.zip" -O $@.download
	mv $@.download $@

zip/tl_2013_us_cbsa.zip:
	mkdir -p $(dir $@)
	wget "ftp://ftp2.census.gov/geo/tiger/TIGER2013/CBSA/tl_2013_us_cbsa.zip" -O $@.download
	mv $@.download $@

zip/region-shp.zip:
	mkdir -p $(dir $@)
	wget "https://s3.amazonaws.com/imi-model-input-XqXP6Ln7xIg8I2Of/shp/region-shp.zip?AWSAccessKeyId=ASIAJNSW3SRH7QKVI37A&Expires=1380123164&Signature=v0VHTRc2/4Ce2zwv0HxL5qHtrZY%3D&x-amz-security-token=AQoDYXdzEDAawAKqRzSe8qpzGh9c4SJjaiy0b2IiXannWgRmF7z0T/jd/15U/Xo%2BMD6VxCKvmo6B%2BKCRW4gz8u/rHyuqVYGsfvbDCD4cPzGp0pfrkejRNSZPfhbOn%2BZAA6JrkPzVjr1aEmmGtYU%2BnVuJc8gFvivjkG2/KGXdZr9gLmI/TPUOwYbTpOPNFLBHxUyA7ZiOoPn/ucnkVfGPj82KyF9ZjawWXtav11%2BYL3LjWQmmUKT%2BxYQJ7khL6Dfdf3uTPU33EpxbOx5I0f8lCa%2B%2BnlCLLTLeVLoIRiJOnsYTomPgSjWnQQQtSvtShb41oIwylSuRQaWhMPpJKx2Ak0Ye5ilXd1aq2Q1ryaiw5OCdyf/vZEMv7i%2BKlvAzW%2ByAS1Rg1sfoHl%2BO5EOwEW/F3dPcIaYNBDgZKNFhpli%2ByYYgGO1pdLzQXNHlZiCf/ouSBQ%3D%3D" -O $@.download
	mv $@.download $@

