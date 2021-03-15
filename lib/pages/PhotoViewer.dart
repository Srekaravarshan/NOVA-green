import 'package:flutter/material.dart';
import 'package:nova_green/Models/ProductModel.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatefulWidget {
  final String url;
  final ProductModel product;
  final int index;

  const PhotoViewer(
      {Key key, this.url, @required this.product, @required this.index})
      : super(key: key);

  @override
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  PageController _pageController;
  List<Widget> pages = [];
  int selectedPage;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedPage = widget.index;
    });
    _pageController = PageController(initialPage: selectedPage);
    setState(() {
      widget.product.photos.forEach((url) {
        pages.add(
          Container(
            child: PhotoView(
              backgroundDecoration: BoxDecoration(color: Colors.white),
              imageProvider: NetworkImage(url),
            ),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Images',
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: pages,
            onPageChanged: (index) {
              setState(() {
                selectedPage = index;
              });
            },
          ),
          widget.product.photos.isEmpty
              ? Container()
              : Positioned.fill(
                  bottom: 25,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        height: 70,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.product.photos.length,
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedPage = index;
                                  _pageController.animateToPage(selectedPage,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeIn);
                                });
                              },
                              child: Align(
                                alignment: Alignment.center,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  height: selectedPage == index ? 70 : 60,
                                  width: selectedPage == index ? 70 : 60,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedPage == index
                                            ? Color(0xFFDA2C38)
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      image: DecorationImage(
                                          image: NetworkImage(widget
                                              .product.photos
                                              .elementAt(index)),
                                          fit: BoxFit.cover)),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(width: 20);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
      // body: Container(
      //   child: PhotoView(
      //     backgroundDecoration: BoxDecoration(color: Colors.white),
      //     imageProvider: NetworkImage(widget.url),
      //   ),
      // ),
    );
  }
}

class SinglePhotoViewer extends StatefulWidget {
  final String url;

  const SinglePhotoViewer({Key key, this.url}) : super(key: key);
  @override
  _SinglePhotoViewerState createState() => _SinglePhotoViewerState();
}

class _SinglePhotoViewerState extends State<SinglePhotoViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Image',
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: PhotoView(
          backgroundDecoration: BoxDecoration(color: Colors.white),
          imageProvider: NetworkImage(widget.url),
        ),
      ),
    );
  }
}
