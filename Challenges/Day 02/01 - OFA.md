**Category:** Warmups  
**Author:** Matt Kiely (HuskyHacks)

![](./files/01%20-%20OFA/01%20-%20OFA.png)

---

The challenge instance displayed a login prompt which seemingly accepted anything for credentials.

![](./files/01%20-%20OFA/01.png)

After logging in, it asked for a six digit code.

![](./files/01%20-%20OFA/02.png)

Entering a random code resulted in a popup message:

![](./files/01%20-%20OFA/03.png)

This was the result of the following JavaScript:

```JavaScript
<script>
    (function() {
      const REAL = "103248";
      const form = document.getElementById('otp-form');
      const code = document.getElementById('code');

      form.addEventListener('submit', function(e) {
        const val = (code.value || '').trim();
        if (!/^\d{6}$/.test(val)) {
          e.preventDefault();
          alert('Please enter a valid 6 digit code.');
          code.focus();
          return;
        }
        if (val !== REAL) {
          e.preventDefault();
          alert('code does not match ' + REAL);
          code.focus();
        }
      });
    })();
  </script>
```

So the code was simply `103248` and never changed. Entering it displayed the flag.

![](./files/01%20-%20OFA/04.png)

Flag: **flag{013cb9b123afec26b572af5087364081}**
