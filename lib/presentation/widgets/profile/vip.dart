import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/profile/settings.dart';

class VipPrivilages  extends StatelessWidget {
  const VipPrivilages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5,),
            SizedBox(
              width: double.infinity,
              height: 90,
              child: Image.asset("assets/images/charmsandmenus.png", fit: BoxFit.cover,)
            ),
            const SizedBox(height: 10,),
            // Vertical Menu List
            Expanded(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ListMenuItem(widget: Image.asset("assets/images/peopleinreview.png", fit: BoxFit.cover,), onTap: () {
                    
                  },),
                  ListMenuItem(widget: Image.asset("assets/images/coinsDiscount.png", fit: BoxFit.cover,), onTap: () {
                    
                  },),
                  ListMenuItem(widget: Image.asset("assets/images/luckyspin.png", fit: BoxFit.cover,), onTap: () {
                    
                  },),
                  ListMenuItem(widget: Image.asset("assets/images/moments.png", fit: BoxFit.cover,), onTap: () {
                    
                  },),
                  ListMenuItem(widget: Image.asset("assets/images/ambassodrs.png", fit: BoxFit.cover,), onTap: () {
                    
                  },),
                  ListMenuItem(widget: Image.asset("assets/images/faq.png", fit: BoxFit.cover,), onTap: () {
                    
                  },),
                  ListMenuItem(widget: Image.asset("assets/images/guidlines.png", fit: BoxFit.cover,), onTap: () {
                    
                  },),
                  ListMenuItem(widget: Image.asset("assets/images/settings.png", fit: BoxFit.cover,), onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),));
                  },),                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopIconMenu extends StatelessWidget {
  final String title;
  final IconData icon;

  const _TopIconMenu({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.black),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ListMenuItem extends StatelessWidget {
  final Widget widget;
  final VoidCallback? onTap;

  const ListMenuItem({super.key, required this.widget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget,
      onTap: onTap,
    );
  }
}