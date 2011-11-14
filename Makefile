#
# This is Alfanous Makefile
#
# Contributers:   
#	Assem chelli <assem.ch@gmail.com>
#

## to do: send version to all integrated tools
## to do: all operations of each extenstion
 
VERSION="4.0.13" 

API_PATH="./src/"
IMPORTER=$(API_PATH)"alfanous/Extensions/Importer/main.py"
DYNAMIC_RESOURCES_PATH=$(API_PATH)"alfanous/dynamic_ressources/"
STORE_PATH="./store/"
INDEX_PATH="./indexes/"
DESKTOP_INTERFACE_PATH="./interfaces/desktop/"


CONFIG_INSTALL_PATH="/usr/share/alfanous-config/"
INDEX_INSTALL_PATH="/usr/share/alfanous-indexes/"
WEB_INSTALL_PATH="/var/alfanous-web/" 





default: 
	@echo "choose a target!"
	
## Kaboom!
all: update_all build_all install_all dist_all  clean_all	 
	@echo "done."



## update store
update_all: update_tanzil  update_recitations update_quranic_corpus update_tanzil
	@echo "done;"

update_traductions:
	# auto download from  http://zekr.org/resources.html to ./store/traductions
	@echo "todo"

update_recitations:
	#  auto download from  http://zekr.org/resources.html to ./store/recitations  + VerseByVerse recitations list
	@echo "todo"

update_quranic_corpus:
	@echo "todo"

update_tanzil:
	@echo "todo"
	



##  build indexes 
index_all: index_main index_extend index_word index_tiny
	@echo "done;"

index_main:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -x main $(STORE_PATH)main.db $(INDEX_PATH)main/

	
index_extend:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -x extend $(STORE_PATH)Traductions/ $(INDEX_PATH)extend/
	
index_word:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -x word $(STORE_PATH)quranic-corpus-morpology.xml $(INDEX_PATH)word/
	
index_tiny:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -x main $(STORE_PATH)tiny.db $(INDEX_PATH)tiny/


## build dynamic_resources 
transfer_all: transfer_stopwords transfer_synonyms transfer_word_props transfer_derivations transfer_ara2eng_names
	@echo "done;"
	
	
transfer_stopwords:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -t stopwords $(STORE_PATH)main.db $(DYNAMIC_RESOURCES_PATH)/
	
transfer_synonyms:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -t synonyms $(STORE_PATH)main.db $(DYNAMIC_RESOURCES_PATH)/

transfer_word_props:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -t word_props $(STORE_PATH)main.db $(DYNAMIC_RESOURCES_PATH)/

transfer_derivations:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -t derivations $(STORE_PATH)main.db $(DYNAMIC_RESOURCES_PATH)/

transfer_ara2eng_names:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -t ara2eng_names $(STORE_PATH)main.db $(DYNAMIC_RESOURCES_PATH)/
	
transfer_antonyms:
	@echo "not yet transfer_antonyms!"


## build spellers
speller_all: speller_aya speller_subject
	@echo "done;"

speller_aya:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -p aya  $(INDEX_PATH)main/

speller_subject:
	export PYTHONPATH=$(API_PATH) ;	python $(IMPORTER) -p subject  $(INDEX_PATH)main/
	


	
## help
help_api:
	cd alfanous/ ; epydoc   --html -v --graph all   --show-imports  -n alfanous -u alfanous.org  . ; 7z a -tzip  alfanous-html.zip ./html/* ;	mv -f alfanous-html.zip ../output ; mv ./html ../doc/API/
	@echo "API help is done!"
	
help:
	@echo "Todo : Manual documentation using sphinx"
	
## Qt forms ,dialogs and resources compilation  
# PyQt is needed  
# apt-get install pyqt4-dev-tools  pyqt-tools  

qt_all:	 qt_uic qt_rcc
	
qt_uic:
	
	cd ./interfaces/desktop ; pyuic4  -o aboutDlg_ui.py UI/aboutDlg.ui
	cd ./interfaces/desktop ; pyuic4  -o preferencesDlg_ui.py UI/preferencesDlg.ui
	cd ./interfaces/desktop ; pyuic4  -o temp.py UI/mainform.ui #-x
	cd ./interfaces/desktop ; sed 's/\"MainWindow\"\,/\"MainWindow\"\,\_(/g' temp.py | sed 's/\, None\,/\)\, None\,/g'| sed 's/from PyQt4/LOCALPATH="\.\/locale\/"\nimport gettext\n\_\=gettext\.gettext\ngettext\.bindtextdomain\(\"alfanousQT\"\, LOCALPATH\)\ngettext\.textdomain\(\"alfanousQT\"\)\nfrom PyQt4/g'    >mainform_ui.py 

qt_rcc:
	pyrcc4 ./resources/images/main.qrc -o ./interfaces/desktop/main_rc.py

	
# localization files
local_pot:
	xgettext $(DESKTOP_INTERFACE_PATH)*.py  --default-domain=alfanousQT --language=Python --keyword=n_ 
	mv alfanousQT.po localization/pot_files/alfanousQT.pot
	# upload the potfile to transifix

local_mo_download:
	@echo "todo"
	#wget ; mv to /localization/locale
##

build_all:  index_all transfer_all speller_all qt_all local_mo_download
	@echo "todo"
	
	
clean_all:
	#the list of file to exclude in building tarball is the same to clean
	@echo "Cleaning"
	rm -rf `find . -name Thumbs.db`
	rm -rf `find . -name *~`
	rm -rf `find . -name *.pyc`
	rm -rf `find . -name *.pyo`
	rm -rf `find . -type d -name *.egg-info`
	

	
## installation
	
install_all: install_api install_desktop install_web
	@echo "done;"
	

install_index: 
	mkdir -p $(INDEX_INSTALL_PATH)
	cp -r ./indexes/main $(INDEX_INSTALL_PATH)
	cp -r ./indexes/extend $(INDEX_INSTALL_PATH)
	
	
install_api: 
	cd   $(API_PATH)/alfanous/ ; python setup.py  install
	
install_desktop: install_index  install_api qt_all 
	cd  ./interfaces/desktop/; sudo python setup.py install
	cp ./resources/launchers/alfanousDesktop /usr/bin/
	cp ./resources/launchers/alfanous.desktop /usr/share/applications/
	cp ./resources/AlFanous.png  /usr/share/pixmaps/
	cp ./resources/fonts/* /usr/share/fonts/
	rm -r 	$(CONFIG_INSTALL_PATH) ; mkdir -p $(CONFIG_INSTALL_PATH); chmod 777  $(CONFIG_INSTALL_PATH)
	#test installation
	#alfanousDesktop
	
	
install_web: 
	#update the indexes and the API if possible 
	# Apache2 needed : apt-get install apache2
	#
	##use always a local copy in the same folder, to make it simple for installation in shared servers
	#copy_files 
	mkdir -p $(WEB_INSTALL_PATH)
	cd ./interfaces/web/ ;  cp ./AGPL $(WEB_INSTALL_PATH)
	cd ./interfaces/web/ ; cp -r site/  $(WEB_INSTALL_PATH)
	cd ./interfaces/web/ ; cp -r cgi/  $(WEB_INSTALL_PATH)
	cd ./interfaces/web/ ;  cp alfanous /etc/apache2/sites-available/ #configure well this file 
	#remove and add the site if exist 
	a2dissite alfanous
	a2ensite alfanous
	#reload apache
	/etc/init.d/apache2 reload
	# change  DNS !?
	
	#test installation
	#firefox 127.0.0.1 &
	
	




##   make packages
dist_all: tarball dist_egg dist_deb dist_rpm dist_sis dist_xpi  dist_app
	@echo "done!"

# python egg for API
dist_egg: alfanous/setup.py
	cd ./alfanous ; python setup.py bdist_egg 
	mkdir -p output/$(VERSION) ; mv ./alfanous/dist/*.egg ./output/$(VERSION)
	@echo  "NOTE: you can find the generated egg in ./output"

# Debian package for AlfanousDesktop
dist_deb: 
	#update files : todo
	
	# build deb
	cd dist/DEB ; @echo "remove these" `find .  -name *~`; sudo rm -rf `find .  -name *~`;
	cd dist/DEB ; sudo nano  alfanous/DEBIAN/changelog
	cd dist/DEB ; sudo nano alfanous/DEBIAN/control
	cd dist/DEB ; dpkg-deb -D --build alfanous alfanous-$(VERSION).deb
	mkdir -p output/$(VERSION) ; mv dist/DEB/alfanous-$(VERSION).deb  ./output/$(VERSION)
	
	# build *_source.changes
	cd dist/DEB/alfanous ; mv DEBIAN debian
	cd dist/DEB/alfanous ; dpkg-buildpackage -S -rfakeroot -k2B2B8B26
	cd dist/DEB/alfanous ; mv debian DEBIAN
	

# Redhat package for AlfanousDesktop
dist_rpm:  
	@echo "todo"
	
# MacOs application
dist_app:  py2app
	@echo "todo"
	
	
# Nokia symbian package for alfanousPyS60 #required python2.5 
dist_sis: python2.5
	 #cd ./interfaces/mobile/Nokia\ S60/alfanousS60 ; python2.5 ensymble.py py2sis --uid=0x07342651 --appname=AlfanousS60 --version=$(VERSION) --lang=EN  --caption="Alfanous - Quranic Search Engine" --vendor="Alfanous.org" main.py AlfanousS60.sis #--icon=icon.svg  --cert=mycert.cer --privkey=mykey.key  
	 @echo "todo"
	
	
# Firefox toolbar
dist_xpi:
	cd ./interfaces/toolbars/firefox/chrome ; zip -r alfanoustoolbar.jar content/* skin/*
	cd ./interfaces/toolbars/firefox ; zip alfanous_toolbar_$(VERSION).xpi install.rdf chrome.manifest chrome/alfanoustoolbar.jar
	mkdir output/$(VERSION) ; mv ./interfaces/toolbars/firefox/alfanous_toolbar_$(VERSION).xpi ./output/$(VERSION)

# the whole project Tarball #attention: what if a bad use of the database! ta7rif?
tarball: clean_all
	tar zcvf ./output/Alfanous_project.tar.gz ./* --exclude=.svn  --exclude=*.egg-info --exclude=Thumbs.db --exclude=*~ --exclude=dist  --exclude=output --exclude=indexes --exclude=tiny  --exclude=Quranic*Indexes --exclude=*.dll --exclude=dev --exclude=ignore --exclude=*.pyc --exclude=*.pyo  # --exclude=html --exclude=web --exclude=*_dyn.py --exclude=Conception --exclude=Desktop --exclude=art --exclude=*_ui.py --exclude=*_rc.py 

# use indexes and dynamic resources  as they are	
tarball_data:
	tar zcvf ./output/Alfanous_project.tar.gz ./* --exclude=.svn --exclude=Thumbs.db --exclude=*~ --exclude=dist  --exclude=output --exclude=store  --exclude=*.dll --exclude=dev  --exclude=*.pyc  --exclude=UI --exclude=*.ui


#dependencies
	
python2.5:
	apt-get install python2.5
	
py2app: easy_install
	easy_install py2app
	
easy_install:
	apt-get install python-distutils*
	

	
	
	

	
	

	