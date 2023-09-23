import React from "react";
import Card from "@mui/material/Card";
import CardActions from "@mui/material/CardActions";
import CardContent from "@mui/material/CardContent";
import Button from "@mui/material/Button";
import Typography from "@mui/material/Typography";

function Home() {
  return (
    <Card>
      <CardContent>
        <Typography>
          Much To Do is a home improvement app that allows for tasks to be prioritized and managed. 
          Associate a task with a room and use the powerful filtering capabilities to help you decide on what your next project will be.
        </Typography>
      </CardContent>
      <CardActions>
        <Button
          size="small"
          href="https://play.google.com/store/apps/details?id=com.joshrap.much_todo&hl=en&gl=US"
          target="_blank"
        >
          Google Play Link
        </Button>
      </CardActions>
    </Card>
  );
}

export default Home;
